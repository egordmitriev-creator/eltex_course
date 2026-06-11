//
//  FetchOffersUseCaseMock.swift
//  TradeAppTests
//
//  Created by egor_dmitriev on 18.05.2026.
//

import Foundation
import XCTest
@testable import TradeApp

final class FetchOffersUseCaseMock: FetchOffersUseCaseProtocol {
    var result: Result<[P2POffer], NetworkError> = .success([
        P2POffer(sellerName: "Seller_0", rate: 1.05, reserve: 200),
        P2POffer(sellerName: "Seller_1", rate: 1.10, reserve: 800)
    ])
    private(set) var executeCalled = false
    private(set) var lastBase: String?
    private(set) var lastTarget: String?

    func execute(base: String,
                 target: String,
                 completion: @escaping (Result<[P2POffer], NetworkError>) -> Void) {
        executeCalled = true
        lastBase   = base
        lastTarget = target
        completion(result)
    }
}
