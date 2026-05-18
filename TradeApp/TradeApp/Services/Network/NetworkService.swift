//
//  NetworkService.swift
//  TradeApp
//
//  Created by egor_dmitriev on 26.04.2026.
//

import Foundation

enum NetworkError: Error {
    case noInternet
    case parsingError
    case unauthorized
    case unknown
}

final class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    func fetchRates(base: String, completion: @escaping (Result<[String: Double], NetworkError>) -> Void) {
        
        guard let url = URL(string: "https://api.frankfurter.app/latest?from=\(base)") else {
            completion(.failure(.unknown))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if error != nil {
                completion(.failure(.noInternet))
                return
            }
            
            if let http = response as? HTTPURLResponse {
                if 400...499 ~= http.statusCode {
                    completion(.failure(.unauthorized))
                    return
                }
            }
            
            guard let data = data else {
                completion(.failure(.parsingError))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(RatesResponse.self, from: data)
                completion(.success(decoded.rates))
            } catch {
                completion(.failure(.parsingError))
            }
            
        }.resume()
    }
    
    func performTrade(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        
        let success = Bool.random()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            if success {
                completion(.success(()))
            } else {
                completion(.failure(.noInternet))
            }
        }
    }
}

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.noInternet, .noInternet),
             (.parsingError, .parsingError),
             (.unauthorized, .unauthorized),
             (.unknown, .unknown): return true
        default: return false
        }
    }
}
