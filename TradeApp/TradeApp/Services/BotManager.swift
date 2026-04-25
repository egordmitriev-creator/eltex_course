//
//  BotManager.swift
//  TradeApp
//
//  Created by egor_dmitriev on 25.04.2026.
//

import Foundation

final class BotManager {
    static let shared = BotManager()
    
    private let queue = DispatchQueue(label: "bot.manager.queue", attributes: .concurrent)
    
    private(set) var bots: [AICurrencyBot] = []
    let wallet: Wallet
    
    init() {
        self.wallet = Wallet(initial: [
            "USD": 10000,
            "BTC": 10,
            "ETH": 100,
            "RUB": 1_000_000
        ])
    }
    
    func register(bot: AICurrencyBot) {
        queue.async(flags: .barrier) {
            self.bots.append(bot)
        }
    }
    
    func runAllBots() -> [DailyBotReport] {
        var allResults: [DailyBotReport] = []
        
        for day in 1...BotConfig.tradingDays {
            
            let group = DispatchGroup()
            var results: [DailyBotReport] = []
            let resultQueue = DispatchQueue(label: "result.queue")
            
            for bot in bots {
                group.enter()
                
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    let report = bot.runDay(wallet: self.wallet, day: day)
                    
                    resultQueue.async {
                        results.append(report)
                        group.leave()
                    }
                }
            }
            
            group.wait()
            allResults.append(contentsOf: results)
        }
        
        return allResults
    }
    
    func getWalletSnapshot() -> [String: Double] {
        wallet.snapshot()
    }
}
