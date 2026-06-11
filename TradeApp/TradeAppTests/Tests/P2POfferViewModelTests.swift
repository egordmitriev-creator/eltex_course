//
//  P2POfferViewModelTests.swift
//  TradeAppTests
//
//  Created by egor_dmitriev on 18.05.2026.
//

import Foundation
import XCTest
@testable import TradeApp

final class P2POfferViewModelTests: XCTestCase {
    func test_rateFormatted_fourDecimalPlaces() {
        let vm = P2POfferViewModel(offer: P2POffer(sellerName: "T", rate: 1.23456789, reserve: 100))
        XCTAssertEqual(vm.rateFormatted, "1.2346")
    }

    func test_reserveFormatted_twoDecimalPlaces() {
        let vm = P2POfferViewModel(offer: P2POffer(sellerName: "T", rate: 1.0, reserve: 500.5))
        XCTAssertEqual(vm.reserveFormatted, "500.50")
    }

    func test_rawValuesPreserved() {
        let vm = P2POfferViewModel(offer: P2POffer(sellerName: "Alice", rate: 0.85, reserve: 999.99))
        XCTAssertEqual(vm.sellerName, "Alice")
        XCTAssertEqual(vm.rate,    0.85,   accuracy: 0.0001)
        XCTAssertEqual(vm.reserve, 999.99, accuracy: 0.0001)
    }
}
