//
//  P2PViewModel.swift
//  TradeApp
//
//  Created by egor_dmitriev on 09.05.2026.
//

import Foundation
import UIKit
internal import os

final class P2PViewModel {
   // MARK: - Bindings
   var onStateChanged: ((P2PScreenState) -> Void)?
   var onWalletUpdated: ((String) -> Void)?
   var onTradeError: ((String) -> Void)?

   // MARK: - State
   private(set) var state: P2PScreenState = .idle {
       didSet { onStateChanged?(state) }
   }

   // MARK: - Dependencies
   weak var coordinator: P2PCoordinatorProtocol?

   private let fetchOffersUseCase: FetchOffersUseCaseProtocol
   private let executeTradeUseCase: ExecuteTradeUseCaseProtocol
   private let dataProvider: CurrenciesDataProviderProtocol

   // MARK: - Init
   init(
       fetchOffersUseCase: FetchOffersUseCaseProtocol = FetchOffersUseCase(),
       executeTradeUseCase: ExecuteTradeUseCaseProtocol = ExecuteTradeUseCase(),
       dataProvider: CurrenciesDataProviderProtocol =  CurrenciesDataProviderService.shared
   ) {
       self.fetchOffersUseCase = fetchOffersUseCase
       self.executeTradeUseCase = executeTradeUseCase
       self.dataProvider = dataProvider

       dataProvider.addObserver { [weak self] in
           DispatchQueue.main.async {
               AppLogger.p2p.debug("Currency pair changed — reloading offers")
               self?.loadOffers()
           }
       }
   }

   // MARK: - Public interface
   func viewDidLoad() {
       AppLogger.p2p.info("P2P screen opened (pair: \(self.pairDescription))")
       loadOffers()
   }

   func didSelectOffer(at index: Int, amountText: String?) {
       guard case .loaded(let offers) = state else {
           AppLogger.p2p.warning("didSelectOffer — called while state is not .loaded, ignoring")
           return
       }

       let offerVM = offers[index]
       let amount = amountText ?? ""
       
       AppLogger.p2p.info("Trade initiated — seller: \(offerVM.sellerName), amount: \(amount) \(self.dataProvider.selectedFirst?.code ?? "?"), rate: \(offerVM.rate, format: .fixed(precision: 6))")

       let input = TradeInput(
           amountText: amountText ?? "",
           base: dataProvider.selectedFirst?.code ?? "",
           quote: dataProvider.selectedSecond?.code ?? "",
           offer: P2POffer(
               sellerName: offerVM.sellerName,
               rate: offerVM.rate,
               reserve: offerVM.reserve
           )
       )

       executeTradeUseCase.execute(input: input) { [weak self] result in
           DispatchQueue.main.async {
               switch result {
               case .success:
                   AppLogger.p2p.info("Trade succeeded — wallet updated (seller: \(offerVM.sellerName))")
                   self?.onWalletUpdated?(self?.walletText ?? "")

               case .failure(let error):
                   let message = self?.tradeErrorMessage(for: error) ?? "Ошибка"
                   AppLogger.p2p.error("Trade failed — \(error.logDescription) (seller: \(offerVM.sellerName), amount: \(amount))")
                   self?.onTradeError?(message)
               }
           }
       }
   }

   func didTapSellerInfo(at index: Int) {
       guard case .loaded(let offers) = state else {
           AppLogger.p2p.warning("didTapSellerInfo — called while state is not .loaded, ignoring")
           return
       }
        
       let offerVM = offers[index]
       AppLogger.p2p.debug("Opening seller detail (seller: \(offerVM.sellerName))")
        
       let detailVM = SellerDetailViewModel(
           sellerName: offerVM.sellerName,
           rate: offerVM.rate,
           reserve: offerVM.reserve,
           completedDeals: Int.random(in: 10...500),
           rating: Double.random(in: 3.5...5.0),
           registrationDate: randomDate(),
           preferredCurrencies: ["USD", "BTC", "ETH"].shuffled().prefix(2).map { $0 },
           isOnline: Bool.random()
       )
       coordinator?.showSellerDetail(detailVM)
   }

   func didTapBack() {
       AppLogger.p2p.debug("User tapped back — dismissing P2P screen")
       coordinator?.dismiss()
   }

   var walletText: String {
       let wallet = BotManager.shared.wallet
       let first = dataProvider.selectedFirst?.code ?? ""
       let second = dataProvider.selectedSecond?.code ?? ""
       return "\(first): \(String(format: "%.2f", wallet.getBalance(first))) | " +
              "\(second): \(String(format: "%.2f", wallet.getBalance(second)))"
   }

   // MARK: - Private
   private func loadOffers() {
       let base = dataProvider.selectedFirst?.code ?? ""
       let target = dataProvider.selectedSecond?.code ?? ""

       guard !base.isEmpty, !target.isEmpty else {
           AppLogger.p2p.error("loadOffers — currency pair is incomplete (base: '\(base)', target: '\(target)')")
           state = .error("Выберите валютную пару")
           return
       }

       AppLogger.p2p.debug("loadOffers — fetching offers (pair: \(base)/\(target))")
       state = .loading

       fetchOffersUseCase.execute(base: base, target: target) { [weak self] result in
           DispatchQueue.main.async {
               switch result {
               case .success(let offers):
                   AppLogger.p2p.info("loadOffers — \(offers.count) offers received (pair: \(base)/\(target))")
                   let viewModels = offers.map { P2POfferViewModel(offer: $0) }
                   self?.state = .loaded(viewModels)
                   self?.onWalletUpdated?(self?.walletText ?? "")

               case .failure(let error):
                   let message = self?.networkErrorMessage(for: error) ?? "Ошибка"
                   AppLogger.p2p.error("loadOffers — failed: \(error.logDescription) (pair: \(base)/\(target))")
                   self?.state = .error(message)
               }
           }
       }
   }

   private func networkErrorMessage(for error: NetworkError) -> String {
       switch error {
       case .noInternet:   return "Нет интернета"
       case .parsingError: return "Ошибка данных"
       case .unauthorized: return "Нет доступа"
       default:            return "Ошибка сети"
       }
   }

   private func tradeErrorMessage(for error: TradeError) -> String {
       switch error {
       case .invalidAmount:
           return "Введите корректное число"
       case .amountNotPositive:
           return "Сумма должна быть больше 0"
       case .insufficientFunds(let available):
           return "Недостаточно средств. Доступно: \(String(format: "%.2f", available))"
       case .networkError(let netError):
           return networkErrorMessage(for: netError)
       }
   }

   private func randomDate() -> Date {
       let daysAgo = Int.random(in: 30...1000)
       return Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
   }

    private var pairDescription: String {
        let first  = dataProvider.selectedFirst?.code  ?? "?"
        let second = dataProvider.selectedSecond?.code ?? "?"
        return "\(first)/\(second)"
    }
}

// MARK: - Log description helpers
private extension TradeError {
    var logDescription: String {
        switch self {
        case .invalidAmount:                  return "invalid amount"
        case .amountNotPositive:               return "amount not positive"
        case .insufficientFunds(let a):         return "insufficient funds (available: \(String(format: "%.2f", a)))"
        case .networkError(let e):             return "network error — \(e.logDescription)"
        }
    }
}

private extension NetworkError {
    var logDescription: String {
        switch self {
        case .noInternet:   return "no internet"
        case .parsingError: return "parsing error"
        case .unauthorized: return "unauthorized"
        case .unknown:     return "unknown"
      }
   }
}
