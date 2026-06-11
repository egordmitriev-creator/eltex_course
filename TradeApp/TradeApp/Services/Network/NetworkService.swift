//
//  NetworkService.swift
//  TradeApp
//
//  Created by egor_dmitriev on 26.04.2026.
//

import Foundation
internal import os

enum NetworkError: Error {
    case noInternet
    case parsingError
    case unauthorized
    case unknown
}

final class NetworkService {
    static let shared = NetworkService()

    private init() {}

    // MARK: - Fetch Rates
    func fetchRates(base: String, completion: @escaping (Result<[String: Double], NetworkError>) -> Void) {

        guard let url = URL(string: "https://api.frankfurter.app/latest?from=\(base)") else {
            AppLogger.network.error("fetchRates — failed to build URL (base: \(base))")
            completion(.failure(.unknown))
            return
        }

        AppLogger.network.debug("fetchRates → GET \(url.absoluteString)")

        URLSession.shared.dataTask(with: url) { data, response, error in

            if let error {
                AppLogger.network.error("fetchRates — no internet: \(error.localizedDescription)")
                completion(.failure(.noInternet))
                return
            }

            if let http = response as? HTTPURLResponse {
                AppLogger.network.debug("fetchRates ← HTTP \(http.statusCode) (base: \(base))")

                if 400...499 ~= http.statusCode {
                    AppLogger.network.error("fetchRates — unauthorized (HTTP \(http.statusCode), base: \(base))")
                    completion(.failure(.unauthorized))
                    return
                }

                if 500...599 ~= http.statusCode {
                    AppLogger.network.error("fetchRates — server error (HTTP \(http.statusCode), base: \(base))")
                    completion(.failure(.unknown))
                    return
                }
            }

            guard let data else {
                AppLogger.network.error("fetchRates — empty response body (base: \(base))")
                completion(.failure(.parsingError))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(RatesResponse.self, from: data)
                AppLogger.network.info("fetchRates — success, \(decoded.rates.count) rates received (base: \(base))")
                completion(.success(decoded.rates))
            } catch {
                AppLogger.network.error("fetchRates — decoding failed: \(error.localizedDescription) (base: \(base))")
                completion(.failure(.parsingError))
            }

        }.resume()
    }

    // MARK: - Perform Trade
    func performTrade(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        let success = Bool.random()
        AppLogger.network.debug("performTrade — request sent, awaiting simulated response")

        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            if success {
                AppLogger.network.info("performTrade — transaction confirmed by server")
                completion(.success(()))
            } else {
                AppLogger.network.error("performTrade — transaction rejected (simulated no-internet)")
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
