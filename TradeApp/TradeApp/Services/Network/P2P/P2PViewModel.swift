//
//  P2PViewModel.swift
//  TradeApp
//
//  Created by egor_dmitriev on 09.05.2026.
//

import Foundation
import UIKit

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
   private let dataProvider: CurrenciesDataProviderService

   // MARK: - Init
   init(
       fetchOffersUseCase: FetchOffersUseCaseProtocol = FetchOffersUseCase(),
       executeTradeUseCase: ExecuteTradeUseCaseProtocol = ExecuteTradeUseCase(),
       dataProvider: CurrenciesDataProviderService = .shared
   ) {
       self.fetchOffersUseCase = fetchOffersUseCase
       self.executeTradeUseCase = executeTradeUseCase
       self.dataProvider = dataProvider

       dataProvider.addObserver { [weak self] in
           DispatchQueue.main.async { self?.loadOffers() }
       }
   }

   // MARK: - Public interface
   func viewDidLoad() {
       loadOffers()
   }

   func didSelectOffer(at index: Int, amountText: String?) {
       guard case .loaded(let offers) = state else { return }

       let offerVM = offers[index]

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
                   self?.onWalletUpdated?(self?.walletText ?? "")
               case .failure(let error):
                   self?.onTradeError?(self?.tradeErrorMessage(for: error) ?? "Ошибка")
               }
           }
       }
   }

   func didTapSellerInfo(at index: Int) {
       guard case .loaded(let offers) = state else { return }
       let offerVM = offers[index]

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

       state = .loading

       fetchOffersUseCase.execute(base: base, target: target) { [weak self] result in
           DispatchQueue.main.async {
               switch result {
               case .success(let offers):
                   let viewModels = offers.map { P2POfferViewModel(offer: $0) }
                   self?.state = .loaded(viewModels)
                   self?.onWalletUpdated?(self?.walletText ?? "")

               case .failure(let error):
                   self?.state = .error(self?.networkErrorMessage(for: error) ?? "Ошибка")
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
}
