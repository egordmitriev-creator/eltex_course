//
//  P2PRepository.swift
//  TradeApp
//
//  Created by egor_dmitriev on 10.05.2026.
//

import Foundation

// MARK: - Protocol
protocol P2PRepositoryProtocol {
    func fetchOffers(base: String, target: String, completion: @escaping (Result<[P2POffer], NetworkError>) -> Void)
}
 
// MARK: - Implementation
final class P2PRepository: P2PRepositoryProtocol {
    private let network: NetworkService
    private let service: P2PService
 
    init(network: NetworkService = .shared,
         service: P2PService = P2PService()) {
        self.network = network
        self.service = service
    }
 
    func fetchOffers(base: String,
                     target: String,
                     completion: @escaping (Result<[P2POffer], NetworkError>) -> Void) {
        network.fetchRates(base: base) { [weak self] result in
            switch result {
            case .success(let rates):
                let offers = self?.service.generateOffers(rates: rates, target: target) ?? []
                completion(.success(offers))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
 
