//
//  P2PCoordinatorMock.swift
//  TradeAppTests
//
//  Created by egor_dmitriev on 18.05.2026.
//

import Foundation
import XCTest
@testable import TradeApp

final class P2PCoordinatorMock: P2PCoordinatorProtocol {
    private(set) var showSellerDetailCalled = false
    private(set) var dismissCalled = false
    private(set) var lastSellerVM: SellerDetailViewModel?

    func start() -> UINavigationController {
        UINavigationController()
    }

    func showSellerDetail(_ seller: SellerDetailViewModel) {
        showSellerDetailCalled = true
        lastSellerVM = seller
    }

    func dismiss() {
        dismissCalled = true
    }
}
