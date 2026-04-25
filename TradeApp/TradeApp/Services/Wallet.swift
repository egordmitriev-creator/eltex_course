//
//  Wallet.swift
//  TradeApp
//
//  Created by egor_dmitriev on 25.04.2026.
//

import Foundation

final class Wallet {
    private let queue = DispatchQueue(label: "wallet.queue", attributes: .concurrent)
    
    private var balances: [String: Double] = [:]
    private var credit: [String: Double] = [:]
    
    init(initial: [String: Double]) {
        self.balances = initial
    }
    
    func getBalance(_ currency: String) -> Double {
        queue.sync {
            balances[currency, default: 0]
        }
    }
    
    func updateBalance(currency: String, delta: Double) {
        queue.async(flags: .barrier) {
            let newValue = (self.balances[currency, default: 0] + delta)
            
            if newValue <= 0 {
                let refill = 1000.0
                self.credit[currency, default: 0] += refill
                self.balances[currency, default: 0] += refill
            }
            
            self.balances[currency, default: 0] = newValue
        }
    }
    
    func snapshot() -> [String: Double] {
        queue.sync { balances }
    }
    
    func creditInfo() -> [String: Double] {
        queue.sync { credit }
    }
}
