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
final class CurrenciesDataProviderService: NSObject {
    
    // MARK: - Properties
    private(set) var currencies: [Currency] = []
    private(set) var filteredCurrencies: [Currency] = []
    
    private(set) var selectedFirst: Currency?
    private(set) var selectedSecond: Currency?
    
    private(set) var rate: Double = 1.0
    
    private var timer: Timer?
    private var secondsLeft = 5
    
    var selectingSide: SelectedSide = .first
    var onCurrencyChange: (() -> Void)?
    
    override init() {
        super.init()
        generateCurrencies()
        selectedFirst = currencies[0]
        selectedSecond = currencies[1]
        applyFilter(filterIndex: 0)
    }
    
    // MARK: - Data Manipulation
    func generateCurrencies() {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        currencies.removeAll()
        
        for i in 0..<120 {
            let code = String((0..<3).map { _ in letters.randomElement()! })
            let type: CurrencyType = i % 2 == 0 ? .fiat : .crypto
            currencies.append(Currency(code: code, type: type))
        }
    }
    
    func applyFilter(filterIndex: Int) {
        switch filterIndex {
        case 1:
            filteredCurrencies = currencies.filter { $0.type == .fiat }
        case 2:
            filteredCurrencies = currencies.filter { $0.type == .crypto }
        default:
            filteredCurrencies = currencies
        }
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
        onCurrencyChange?()
    }
    
    func updateRate() {
        rate = Double.random(in: 0.001...1000)
    }
    
    func calculateResult(amount: Double) -> Double {
        return amount * rate
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
        
        cell.update(code: item.code, disabled: disabled)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currency = filteredCurrencies[indexPath.row]
        selectCurrency(currency)
        
        collectionView.reloadData()
    }
}
