//
//  CurrenciesDataProviderMock.swift
//  TradeAppTests
//
//  Created by egor_dmitriev on 18.05.2026.
//

import Foundation
import XCTest
@testable import TradeApp

final class CurrenciesDataProviderMock: CurrenciesDataProviderProtocol {
    var selectedFirst: Currency?  = Currency(code: "USD", type: .fiat)
    var selectedSecond: Currency? = Currency(code: "EUR", type: .fiat)
    private var observers: [() -> Void] = []

    func addObserver(_ observer: @escaping () -> Void) {
        observers.append(observer)
    }

    func triggerUpdate() {
        observers.forEach { $0() }
    }
}
