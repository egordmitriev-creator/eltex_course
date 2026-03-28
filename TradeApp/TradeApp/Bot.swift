//
//  Bot.swift
//  TradeApp
//
//  Created by egor_dmitriev on 19.03.2026.
//

import Foundation
import UIKit

// MARK: Собственная функция для форматирования цены
func formattedPrice(_ price: Double) -> String {
    return String(format: "%.2f", price)
}

// MARK: Перечисление для типа позиции
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

// MARK: Перечисление для типа решения
enum DecisionTypes: String {
    case buy = "Buy"
    case sell = "Sell"
    case ignore = "Ignore"
}

// MARK: Структура для сделки
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

// MARK: Протокол для класса бота
protocol AICurrencyBotProtocol {
    var currency: String { get }
    var balance: Double { get }
    var isPositionOpen: Bool { get }
    
    func startTrading() -> [TradeMessage]
}

// MARK: Основной класс бота
final class AICurrencyBot: AICurrencyBotProtocol {
    let currency: String
    let minPrice: Double
    let maxPrice: Double
        
    // Приватные свойства
    private var iterations: Int
    private var currentPrice: Double = .zero
    private var entryPrice: Double = .zero
    private var positionType: PositionTypes = .none
    private var decisionType: DecisionTypes = .ignore
    private var income: Double = .zero
    //private var outString = ""
    
    private var messages: [TradeMessage] = []
    
    private(set) var balance: Double
    private(set) var isPositionOpen: Bool = false

    // Инициализатор
    init(
        initialBalance: Double = 1000.0,
        iterations: Int = 20,
        currency: String = "USD",
        minPrice: Double = 20.0,
        maxPrice: Double = 150.0
    ) {
        self.balance = initialBalance
        self.iterations = iterations
        self.currency = currency
        self.minPrice = minPrice
        self.maxPrice = maxPrice
    }
        
    // Публичный метод для запуска торговли
    func startTrading() -> [TradeMessage] {
        messages.removeAll()
        
        messages.append(
            TradeMessage(
                id: UUID(),
                text: "Start of trading",
                tradeType: .ignore,
                details: nil
            )
        )
        
        messages.append(
            TradeMessage(
                id: UUID(),
                text: "Start balance: \(formattedPrice(balance))",
                tradeType: .ignore,
                details: nil
            )
        )
        
        for _ in 0...iterations {
            performTradingCycle()
        }
        
        messages.append(
            TradeMessage(
                id: UUID(),
                text: "End of trading",
                tradeType: .ignore,
                details: nil
            )
        )
        
        messages.append(
            TradeMessage(
                id: UUID(),
                text: "Balance: \(formattedPrice(balance)) \(currency)",
                tradeType: .ignore,
                details: nil
            )
        )
        
        return messages
    }
        
    // Приватный метод для одного цикла торговли
    private func performTradingCycle() {
        currentPrice = Double.random(in: minPrice...maxPrice)
        decisionType = .ignore
            
        if !isPositionOpen {
            let randomDecision = Int.random(in: 0...2)
            switch randomDecision {
            case 0:
                decisionType = .buy
                positionType = .buy
                entryPrice = currentPrice
                isPositionOpen = true
                messages.append(
                    TradeMessage(
                        id: UUID(),
                        text: "Opening a position: Buy at \(formattedPrice(currentPrice)) \(currency)",
                        tradeType: .buy,
                        details: nil
                    )
                )
            case 1:
                decisionType = .sell
                positionType = .sell
                entryPrice = currentPrice
                isPositionOpen = true
                messages.append(
                    TradeMessage(
                        id: UUID(),
                        text: "Opening a position: sell at \(formattedPrice(currentPrice)) \(currency)",
                        tradeType: .sell,
                        details: nil
                    )
                )
            default:
                decisionType = .ignore
            }
        } else {
            let shouldClose = Bool.random()
            if shouldClose {
                let trade = Trade(
                    type: positionType,
                    entryPrice: entryPrice,
                    exitPrice: currentPrice
                )
                    
                income = trade.income
                balance += income
                decisionType = (positionType == .buy) ? .sell : .buy
                messages.append(
                    TradeMessage(
                        id: UUID(),
                        text: "Closing a position",
                        tradeType: decisionType,
                        details: trade.tradeInfo()
                    )
                )
                isPositionOpen = false
                positionType = .none
            }
        }
        
        messages.append(
            TradeMessage(
                id: UUID(),
                text: "\(formattedPrice(currentPrice)) \(currency)",
                tradeType: decisionType,
                details: nil
            )
        )
    }
}

// MARK: - Extension
extension AICurrencyBot {
    var currentBalance: Double {
        return balance
    }
    
    var positionStatus: Bool {
        return isPositionOpen
    }
    
    func getStatus() -> String {
        var status = "\nСтатус бота\n"
        status += "Баланс: \(formattedPrice(balance)) \(currency)\n"
        status += "Позиция открыта: \(isPositionOpen ? "Да" : "Нет")\n"
        if isPositionOpen {
            status += "Тип позиции: \(positionType.rawValue)\n"
            status += "Цена входа: \(formattedPrice(entryPrice)) \(currency)\n"
        }
        return status
    }
}
