//
//  P2PRepositoryMock.swift
//  TradeAppTests
//
//  Created by egor_dmitriev on 18.05.2026.
//

import Foundation
import XCTest
@testable import TradeApp

final class P2PRepositoryMock: P2PRepositoryProtocol {
    var result: Result<[P2POffer], NetworkError> = .success([
        P2POffer(sellerName: "Alice", rate: 1.1, reserve: 500),
        P2POffer(sellerName: "Bob",   rate: 1.2, reserve: 1000)
    ])

    func fetchOffers(base: String,
                     target: String,
                     completion: @escaping (Result<[P2POffer], NetworkError>) -> Void) {
        completion(result)
    }
}
