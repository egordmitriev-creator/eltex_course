//
//  RatesResponse.swift
//  TradeApp
//
//  Created by egor_dmitriev on 27.04.2026.
//

import Foundation

struct RatesResponse: Decodable {
    let rates: [String: Double]
}
