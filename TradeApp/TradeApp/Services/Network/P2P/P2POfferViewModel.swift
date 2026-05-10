//
//  P2POfferViewModel.swift
//  TradeApp
//
//  Created by egor_dmitriev on 10.05.2026.
//

import Foundation

struct P2POfferViewModel {
    let sellerName: String
    let rateFormatted: String
    let reserveFormatted: String
    let rate: Double
    let reserve: Double
 
    init(offer: P2POffer) {
        self.sellerName = offer.sellerName
        self.rateFormatted = String(format: "%.4f", offer.rate)
        self.reserveFormatted = String(format: "%.2f", offer.reserve)
        self.rate = offer.rate
        self.reserve = offer.reserve
    }
}
 
