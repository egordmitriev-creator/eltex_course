//
//  P2PServiceTests.swift
//  TradeAppTests
//
//  Created by egor_dmitriev on 18.05.2026.
//

import Foundation
import XCTest
@testable import TradeApp

final class P2PServiceTests: XCTestCase {
    private let service = P2PService()

    func test_generateOffers_missingTarget_returnsEmpty() {
        let offers = service.generateOffers(rates: ["EUR": 0.9], target: "BTC")
        XCTAssertTrue(offers.isEmpty)
    }

    func test_generateOffers_validTarget_returns10Offers() {
        let offers = service.generateOffers(rates: ["EUR": 0.9], target: "EUR")
        XCTAssertEqual(offers.count, 10)
    }

    func test_generateOffers_sortedDescendingByRate() {
        let offers = service.generateOffers(rates: ["EUR": 1.0], target: "EUR")
        for i in 0..<(offers.count - 1) {
            XCTAssertGreaterThanOrEqual(
                offers[i].rate, offers[i + 1].rate,
                "Офферы должны быть отсортированы по убыванию курса"
            )
        }
    }

    func test_generateOffers_ratesWithinFivePercent() {
        let base = 1.0
        let offers = service.generateOffers(rates: ["USD": base], target: "USD")
        for offer in offers {
            let deviation = abs(offer.rate - base) / base
            XCTAssertLessThanOrEqual(deviation, 0.06,
                "Отклонение курса не должно превышать 5% (+погрешность округления)")
        }
    }

    func test_generateOffers_uniqueSellerNames() {
        let offers = service.generateOffers(rates: ["USD": 1.0], target: "USD")
        let names = Set(offers.map { $0.sellerName })
        XCTAssertEqual(names.count, offers.count, "Имена продавцов должны быть уникальными")
    }
}
