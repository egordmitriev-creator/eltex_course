//
//  P2PScreenStateTests.swift
//  TradeAppTests
//
//  Created by egor_dmitriev on 18.05.2026.
//

import Foundation
import XCTest
@testable import TradeApp

final class P2PScreenStateTests: XCTestCase {
    func test_idleState() {
        if case .idle = P2PScreenState.idle { } else { XCTFail("Ожидался .idle") }
    }

    func test_loadingState() {
        if case .loading = P2PScreenState.loading { } else { XCTFail("Ожидался .loading") }
    }

    func test_loadedState_holdsOffers() {
        let vm = P2POfferViewModel(offer: P2POffer(sellerName: "X", rate: 1, reserve: 10))
        if case .loaded(let vms) = P2PScreenState.loaded([vm]) {
            XCTAssertEqual(vms.count, 1)
        } else {
            XCTFail("Ожидался .loaded")
        }
    }

    func test_errorState_holdsMessage() {
        if case .error(let msg) = P2PScreenState.error("Нет интернета") {
            XCTAssertEqual(msg, "Нет интернета")
        } else {
            XCTFail("Ожидался .error")
        }
    }
}
