//
//  Candle.swift
//  TradeApp
//
//  Created by egor_dmitriev on 26.04.2026.
//

// MARK: Candle struct
struct Candle {
    let open: Double
    let close: Double
    let high: Double
    let low: Double
    
    var isBullish: Bool {
        close >= open
    }
}
