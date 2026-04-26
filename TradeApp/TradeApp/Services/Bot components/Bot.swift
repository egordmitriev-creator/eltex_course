//
//  Bot.swift
//  TradeApp
//
//  Created by egor_dmitriev on 19.03.2026.
//

import Foundation
import UIKit

func formattedPrice(_ price: Double) -> String {
    return String(format: "%.2f", price)
}

enum PositionTypes: String {
    case buy = "Buy"
    case sell = "Sell"
    case none = "None"
    
    var opposite: PositionTypes {
        switch self {
        case .buy:
            return .sell
        case .sell:
            return .buy
        case .none:
            return .none
        }
    }
}

enum DecisionTypes: String {
    case buy = "Buy"
    case sell = "Sell"
    case ignore = "Ignore"
}

struct Trade {
    let type: PositionTypes
    let entryPrice: Double
    let exitPrice: Double
    
    var income: Double {
        switch type {
        case .buy:
            return exitPrice - entryPrice
        case .sell:
            return entryPrice - exitPrice
        case .none:
            return 0.0
        }
    }
    
    func tradeInfo() -> String {
        return "\(type.rawValue) FROM = \(formattedPrice(entryPrice)) -> TO = \(formattedPrice(exitPrice)), INCOME = \(formattedPrice(income))"
    }
}

protocol AICurrencyBotProtocol {
    var name: String { get }
    var pair: String { get }
    
    func runDay(wallet: Wallet, day: Int) -> DailyBotReport
}

// MARK: Main class
final class AICurrencyBot: AICurrencyBotProtocol {
    let name: String
    let pair: String
    
    init(name: String, pair: String) {
        self.name = name
        self.pair = pair
    }
    
    func runDay(wallet: Wallet, day: Int) -> DailyBotReport {
        let operations = Int.random(
            in: BotConfig.minOperationsPerDay...BotConfig.maxOperationsPerDay
        )
        
        let currencies = pair.components(separatedBy: "-")
        let base = currencies[0]
        let quote = currencies[1]
        
        let startSnapshot = wallet.snapshot()
        
        DispatchQueue.concurrentPerform(iterations: operations) { _ in
            let price = Double.random(in: 10...100)
            let isBuy = Bool.random()
            
            if isBuy {
                wallet.updateBalance(currency: base, delta: -1)
                wallet.updateBalance(currency: quote, delta: price)
            } else {
                wallet.updateBalance(currency: base, delta: 1)
                wallet.updateBalance(currency: quote, delta: -price)
            }
        }
        
        let endSnapshot = wallet.snapshot()
        
        var income: Double = 0
        for (currency, startValue) in startSnapshot {
            let endValue = endSnapshot[currency] ?? 0
            income += endValue - startValue
        }
        
        return DailyBotReport(
            botName: name,
            pair: pair,
            day: day,
            income: income
        )
    }
}
