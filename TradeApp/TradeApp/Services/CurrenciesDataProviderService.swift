//
//  CurrenciesDataProviderService.swift
//  TradeApp
//
//  Created by egor_dmitriev on 02.04.2026.
//

import Foundation
import UIKit

// MARK: - Model
struct Currency {
    let code: String
    let type: CurrencyType
}

enum CurrencyType {
    case fiat
    case crypto
}

enum SelectedSide {
    case first
    case second
}

// MARK: - Data Provider
final class CurrenciesDataProviderService: NSObject, CurrencyCellDelegate {
    // MARK: - Properties
    private(set) var currencies: [Currency] = []
    private(set) var filteredCurrencies: [Currency] = []
    private(set) var selectedFirst: Currency?
    private(set) var selectedSecond: Currency?
    private(set) var rate: Double = .zero
    
    private var apiCurrencies: [Currency] = []
    private var isAPIMode: Bool = false
    
    private var timer: Timer?
    private var secondsLeft: Int = .zero
    private var favorites: Set<String> = []
    private var currentFilteredIndex: Int = .zero
    private var observers: [() -> Void] = []
    
    static let shared = CurrenciesDataProviderService()
    
    var selectingSide: SelectedSide = .first
    var isFavoritesEnabled: Bool = false
    
    override init() {
        super.init()
        //generateCurrencies()
        loadDefaultCurrencies()
        selectedFirst = currencies[0]
        selectedSecond = currencies[1]
        
        loadCurrenciesFromAPI(base: selectedFirst?.code ?? "USD")
        
        applyFilter(filterIndex: 0)
    }
}

private extension CurrenciesDataProviderService {
    func notifyObservers() {
        observers.forEach { $0() }
    }
    
    func loadDefaultCurrencies() {
        currencies = [
            Currency(code: "USD", type: .fiat),
            Currency(code: "EUR", type: .fiat),
            Currency(code: "RUB", type: .fiat),
            Currency(code: "BTC", type: .crypto),
            Currency(code: "ETH", type: .crypto)
        ]
    }
    
    func generateCurrencies() {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        currencies.removeAll()
        
        for i in 0..<120 {
            let code = String((0..<3).map { _ in letters.randomElement()! })
            let type: CurrencyType = i % 2 == 0 ? .fiat : .crypto
            currencies.append(Currency(code: code, type: type))
        }
    }
    
    func updateRate() {
        rate = Double.random(in: 0.001...1000)
    }
}

extension CurrenciesDataProviderService {
    func applyCurrentFilters() {
        var result: [Currency]
        
        if isAPIMode {
            result = apiCurrencies
        } else {
            result = currencies
            
            if !apiCurrencies.isEmpty {
                let existingCodes = Set(result.map { $0.code })
                
                let newFromAPI = apiCurrencies.filter { !existingCodes.contains($0.code) }
                result.append(contentsOf: newFromAPI)
            }
        }
        
        switch currentFilteredIndex {
        case 1:
            result = result.filter { $0.type == .fiat }
        case 2:
            result = result.filter { $0.type == .crypto }
        default:
            break
        }
        
        if isFavoritesEnabled {
            result = result.filter { favorites.contains($0.code) }
        }
        
        filteredCurrencies = result
    }
    
    func applyFilter(filterIndex: Int) {
        currentFilteredIndex = filterIndex
        applyCurrentFilters()
    }
    
    func calculateResult(amount: Double) -> Double {
        return amount * rate
    }
    
    func selectCurrency(_ currency: Currency) {
        guard let first = selectedFirst, let second = selectedSecond else { return }
        guard currency.code != first.code && currency.code != second.code else { return }
        
        if selectingSide == .first {
            selectedFirst = currency
        } else {
            selectedSecond = currency
        }
        
        updateRate()
        notifyObservers()
    }
    
    // MARK: - Timer
    func startTimer(update: @escaping (Int) -> Void, onRateUpdate: @escaping () -> Void) {
        timer?.invalidate()
        secondsLeft = 5
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.secondsLeft -= 1
            update(self.secondsLeft)
            
            if self.secondsLeft == 0 {
                self.secondsLeft = 5
                self.updateRate()
                onRateUpdate()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func addObserver(_ observer: @escaping () -> Void) {
        observers.append(observer)
    }
    
    func selectRandomPair() {
        guard currencies.count >= 2 else { return }
        
        let shuffled = currencies.shuffled()
        selectedFirst = shuffled[0]
        selectedSecond = shuffled[1]
        
        updateRate()
        notifyObservers()
    }
}

// MARK: - Collection View
extension CurrenciesDataProviderService: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredCurrencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = filteredCurrencies[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrencyCell.identifier, for: indexPath) as? CurrencyCell else {
            return UICollectionViewCell()
        }
        
        let disabled = (selectedFirst?.code == item.code) || (selectedSecond?.code == item.code)
        
        cell.delegate = self
        cell.update(
            code: item.code,
            disabled: disabled,
            isFavorite: favorites.contains(item.code)
        )
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currency = filteredCurrencies[indexPath.row]
        
        let oldFirst = selectedFirst
        let oldSecond = selectedSecond
        
        selectCurrency(currency)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? CurrencyCell {
            cell.animateSelection()
        }
        
        var indexPathsToReload: [IndexPath] = [indexPath]
        
        if let oldFirst = oldFirst,
           let index = filteredCurrencies.firstIndex(where: { $0.code == oldFirst.code }) {
            indexPathsToReload.append(IndexPath(row: index, section: 0))
        }
        
        if let oldSecond = oldSecond,
           let index = filteredCurrencies.firstIndex(where: { $0.code == oldSecond.code }) {
            indexPathsToReload.append(IndexPath(row: index, section: 0))
        }
        
        collectionView.reloadItems(at: indexPathsToReload)
    }
}

extension CurrenciesDataProviderService: UICollisionBehaviorDelegate {
    func didTapFavorite(code: String) {
        if favorites.contains(code) {
            favorites.remove(code)
        } else {
            favorites.insert(code)
        }
        applyCurrentFilters()
        notifyObservers()
    }
}

// MARK: P2P
extension CurrenciesDataProviderService {
    func loadCurrenciesFromAPI(base: String) {
        NetworkService.shared.fetchRates(base: base) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let rates):
                    self?.apiCurrencies = rates.keys.map {
                        Currency(code: $0, type: self?.detectType(code: $0) ?? .fiat)
                    }
                    self?.applyCurrentFilters()
                    self?.notifyObservers()
                    
                case .failure:
                    break
                }
            }
        }
    }
    
    private func detectType(code: String) -> CurrencyType {
        let crypto = ["BTC", "ETH"]
        return crypto.contains(code) ? .crypto : .fiat
    }
    
    func setAPIMode(_ enabled: Bool) {
        isAPIMode = enabled
        
        if enabled {
            loadCurrenciesFromAPI(base: selectedFirst?.code ?? "USD")
        }
        
        applyCurrentFilters()
        notifyObservers()
    }
}
