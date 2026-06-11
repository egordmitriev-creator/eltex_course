//
//  P2PService.swift
//  TradeApp
//
//  Created by egor_dmitriev on 27.04.2026.
//

import Foundation
internal import os

final class P2PService {
    func generateOffers(rates: [String: Double], target: String) -> [P2POffer] {
        guard let baseRate = rates[target] else {
            AppLogger.p2p.warning("generateOffers — target currency not found in rates (target: \(target), available: \(rates.keys.sorted().joined(separator: ", ")))")
            return []
        }

        AppLogger.p2p.debug("generateOffers — generating 10 offers (target: \(target), baseRate: \(baseRate, format: .fixed(precision: 6)))")

        var offers: [P2POffer] = []

        for i in 0..<10 {
            let randomPercent = Double.random(in: -0.05...0.05)
            let price = baseRate * (1 + randomPercent)

            let offer = P2POffer(
                sellerName: "Seller_\(i)",
                rate: price,
                reserve: Double.random(in: 100...10000)
            )
            offers.append(offer)
        }

        let sorted = offers.sorted { $0.rate > $1.rate }

        AppLogger.p2p.info("generateOffers — done, best rate: \(sorted.first?.rate ?? 0, format: .fixed(precision: 6)), worst: \(sorted.last?.rate ?? 0, format: .fixed(precision: 6)) (target: \(target))")

        return sorted
    }
}
