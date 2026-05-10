//
//  FetchOffersUseCase.swift
//  TradeApp
//
//  Created by egor_dmitriev on 10.05.2026.
//

import Foundation

// MARK: - Protocol
protocol FetchOffersUseCaseProtocol {
   func execute(base: String, target: String, completion: @escaping (Result<[P2POffer], NetworkError>) -> Void)
}

// MARK: - Implementation
final class FetchOffersUseCase: FetchOffersUseCaseProtocol {
   private let repository: P2PRepositoryProtocol

   init(repository: P2PRepositoryProtocol = P2PRepository()) {
       self.repository = repository
   }

   func execute(base: String,
                target: String,
                completion: @escaping (Result<[P2POffer], NetworkError>) -> Void) {
       guard !base.isEmpty, !target.isEmpty else {
           completion(.success([]))
           return
       }
       repository.fetchOffers(base: base, target: target, completion: completion)
   }
}
