//
//  ExecuteTradeUseCaseMock.swift
//  TradeAppTests
//
//  Created by egor_dmitriev on 18.05.2026.
//

import Foundation
import XCTest
@testable import TradeApp

final class ExecuteTradeUseCaseMock: ExecuteTradeUseCaseProtocol {
    var result: Result<Void, TradeError> = .success(())
    private(set) var executeCalled = false
    private(set) var lastInput: TradeInput?

    func execute(input: TradeInput,
                 completion: @escaping (Result<Void, TradeError>) -> Void) {
        executeCalled = true
        lastInput = input
        completion(result)
    }
}
