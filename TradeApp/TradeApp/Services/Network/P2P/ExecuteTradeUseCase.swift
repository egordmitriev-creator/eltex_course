//
//  ExecuteTradeUseCase.swift
//  TradeApp
//
//  Created by egor_dmitriev on 10.05.2026.
//

import Foundation

// MARK: - Errors
enum TradeError: Error {
    case invalidAmount
    case amountNotPositive
    case insufficientFunds(available: Double)
    case networkError(NetworkError)
}
 
// MARK: - Input
struct TradeInput {
    let amountText: String
    let base: String
    let quote: String
    let offer: P2POffer
}
 
// MARK: - Protocol
protocol ExecuteTradeUseCaseProtocol {
    func execute(input: TradeInput, completion: @escaping (Result<Void, TradeError>) -> Void)
}
 
// MARK: - Implementation
final class ExecuteTradeUseCase: ExecuteTradeUseCaseProtocol {
    private let network: NetworkService
    private let wallet: Wallet
 
    init(network: NetworkService = .shared,
         wallet: Wallet = BotManager.shared.wallet) {
        self.network = network
        self.wallet = wallet
    }
 
    func execute(input: TradeInput,
                 completion: @escaping (Result<Void, TradeError>) -> Void) {
 
        // 1. Summ validate
        guard let amount = Double(input.amountText) else {
            completion(.failure(.invalidAmount))
            return
        }
 
        guard amount > 0 else {
            completion(.failure(.amountNotPositive))
            return
        }
 
        // 2. Ballance checking
        let balance = wallet.getBalance(input.base)
        guard amount <= balance else {
            completion(.failure(.insufficientFunds(available: balance)))
            return
        }
 
        // 3. Network request (transaction confirmation)
        network.performTrade { [weak self] result in
            switch result {
            case .success:
                // 4. Wallet update
                self?.wallet.updateBalance(currency: input.base, delta: -amount)
                self?.wallet.updateBalance(currency: input.quote, delta: amount * input.offer.rate)
                completion(.success(()))
 
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
    }
}
 
