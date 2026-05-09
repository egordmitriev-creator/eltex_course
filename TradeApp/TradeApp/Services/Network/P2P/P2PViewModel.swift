//
//  P2PViewModel.swift
//  TradeApp
//
//  Created by egor_dmitriev on 09.05.2026.
//

import Foundation
import UIKit

// MARK: - Offer display model
struct P2POfferViewModel {
    let sellerName: String
    let rateFormatted: String
    let reserveFormatted: String
    let rate: Double
    let reserve: Double
 
    init(offer: P2POffer) {
        self.sellerName = offer.sellerName
        self.rateFormatted = String(format: "%.4f", offer.rate)
        self.reserveFormatted = String(format: "%.2f", offer.reserve)
        self.rate = offer.rate
        self.reserve = offer.reserve
    }
}
 
// MARK: - ViewModel
final class P2PViewModel {
    // MARK: Bindings
    var onOffersUpdated: (() -> Void)?
    var onWalletUpdated: ((String) -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
 
    // MARK: Data
    private(set) var offers: [P2POfferViewModel] = []
 
    // MARK: Dependencies
    weak var coordinator: P2PCoordinatorProtocol?
 
    private let dataProvider = CurrenciesDataProviderService.shared
    private let network = NetworkService.shared
    private let service = P2PService()
 
    // MARK: Init
    init() {
        dataProvider.addObserver { [weak self] in
            DispatchQueue.main.async { self?.loadData() }
        }
    }
 
    // MARK: Public
    func viewDidLoad() {
        loadData()
    }
 
    func didSelectOffer(at index: Int, amountText: String?) {
        guard let text = amountText, let amount = Double(text) else {
            onError?("Введите корректное число")
            return
        }
 
        guard amount > 0 else {
            onError?("Сумма должна быть больше 0")
            return
        }
 
        let wallet = BotManager.shared.wallet
        let base = dataProvider.selectedFirst?.code ?? ""
        let balance = wallet.getBalance(base)
 
        guard amount <= balance else {
            onError?("Недостаточно средств")
            return
        }
 
        let offer = offers[index]
 
        network.performTrade { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.applyTrade(amount: amount, offer: offer)
                case .failure(let error):
                    self?.onError?(self?.errorMessage(for: error) ?? "Ошибка")
                }
            }
        }
    }
 
    func didTapSellerInfo(at index: Int) {
        let offer = offers[index]
        let detailVM = SellerDetailViewModel(
            sellerName: offer.sellerName,
            rate: offer.rate,
            reserve: offer.reserve,
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
        let b1 = wallet.getBalance(first)
        let b2 = wallet.getBalance(second)
        return "\(first): \(String(format: "%.2f", b1)) | \(second): \(String(format: "%.2f", b2))"
    }
 
    // MARK: Private
    private func loadData() {
        guard let base = dataProvider.selectedFirst?.code else { return }
        onLoadingChanged?(true)
 
        network.fetchRates(base: base) { [weak self] result in
            DispatchQueue.main.async {
                self?.onLoadingChanged?(false)
                switch result {
                case .success(let rates):
                    guard let target = self?.dataProvider.selectedSecond?.code else { return }
                    let raw = self?.service.generateOffers(rates: rates, target: target) ?? []
                    self?.offers = raw.map { P2POfferViewModel(offer: $0) }
                    self?.onOffersUpdated?()
                    self?.onWalletUpdated?(self?.walletText ?? "")
                case .failure(let error):
                    self?.onError?(self?.errorMessage(for: error) ?? "Ошибка")
                }
            }
        }
    }
 
    private func applyTrade(amount: Double, offer: P2POfferViewModel) {
        let wallet = BotManager.shared.wallet
        guard let base = dataProvider.selectedFirst?.code,
              let quote = dataProvider.selectedSecond?.code else { return }
 
        wallet.updateBalance(currency: base, delta: -amount)
        wallet.updateBalance(currency: quote, delta: amount * offer.rate)
        onWalletUpdated?(walletText)
    }
 
    private func errorMessage(for error: NetworkError) -> String {
        switch error {
        case .noInternet:   return "Нет интернета"
        case .parsingError: return "Ошибка данных"
        case .unauthorized: return "Нет доступа"
        default:            return "Ошибка"
        }
    }
 
    private func randomDate() -> Date {
        let daysAgo = Int.random(in: 30...1000)
        return Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
    }
}
