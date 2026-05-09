//
//  SellerDetailViewModel.swift
//  TradeApp
//
//  Created by egor_dmitriev on 09.05.2026.
//

import Foundation

struct SellerDetailViewModel {
    let sellerName: String
    let rate: Double
    let reserve: Double
    let completedDeals: Int
    let rating: Double              // 0–5
    let registrationDate: Date
    let preferredCurrencies: [String]
    let isOnline: Bool
 
    var rateFormatted: String    { String(format: "%.4f", rate) }
    var reserveFormatted: String { String(format: "%.2f", reserve) }
    var ratingFormatted: String  { String(format: "%.1f", rating) }
 
    var registrationDateFormatted: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: registrationDate)
    }
 
    var onlineStatus: String { isOnline ? "🟢 Online" : "⚫️ Offline" }
}
