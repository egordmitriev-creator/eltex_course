//
//  P2PService.swift
//  TradeApp
//
//  Created by egor_dmitriev on 27.04.2026.
//

import Foundation

final class P2PService {
    func generateOffers(rates: [String: Double], target: String) -> [P2POffer] {
        guard let baseRate = rates[target] else { return [] }
        
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
        
        return offers.sorted { $0.rate > $1.rate }
    }
}
