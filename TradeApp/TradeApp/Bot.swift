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
    
    func startTrading() -> String
}

// MARK: Основной класс бота
final class AICurrencyBot: AICurrencyBotProtocol {
    let currency: String
    let minPrice: Double
    let maxPrice: Double
        
    // Приватные свойства
    private var iterations: Int
    private var currentPrice: Double = 0.0
    private var entryPrice: Double = 0.0
    private var positionType: PositionTypes = .none
    private var decisionType: DecisionTypes = .ignore
    private var income: Double = 0.0
    private var outString = ""
    
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
    func startTrading() -> String {
        outString += "Начало торговли\n"
        outString += "Стартовый баланс: \(formattedPrice(balance)) \(currency)\n"
        
        for _ in 0...iterations {
            performTradingCycle()
        }
        
        outString += "\nИтог торгов\n"
        outString += "Баланс: \(formattedPrice(balance)) \(currency)"
        
        return outString
    }
        
    // Приватный метод для одного цикла торговли
    private func performTradingCycle() -> String {
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
                outString += "Открытие позиции: Покупка по \(formattedPrice(currentPrice)) \(currency)\n"
            case 1:
                decisionType = .sell
                positionType = .sell
                entryPrice = currentPrice
                isPositionOpen = true
                outString += "Открытие позиции: Продажа по \(formattedPrice(currentPrice)) \(currency)\n"
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
                outString += "Закрытие позиции: \(trade.tradeInfo())\n"
                isPositionOpen = false
                positionType = .none
            } else {
                decisionType = .ignore
            }
        }
        outString += "\(formattedPrice(currentPrice)) \(currency) - \(decisionType.rawValue)\n"
        return outString
    }
}

// MARK: - Extension
extension AICurrencyBot {
    // Реализация требований протокола
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



// MARK: - Запуск бота
//let bot = AICurrencyBot(
//    initialBalance: 1000.0,
//    iterations: 20,
//    currency: "USD",
//    minPrice: 20.0,
//    maxPrice: 150.0
//)
//
//bot.startTrading()
//bot.printStatus()
