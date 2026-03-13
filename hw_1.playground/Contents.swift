import UIKit

var balance: Double = 1000.0
var iterations: Int = 20

let minPrice: Double = 20.0
let maxPrice: Double = 150.0
var currentPrice: Double = 0.0
var entryPrice: Double = 0.0

var isPositionOpen: Bool = false

var positionType: String = ""
var decisionType: String = ""

let currency = "USD"

var income: Double = 0.0

for _ in 0...iterations {
    currentPrice = Double.random(in: minPrice...maxPrice)
    decisionType = "Ignore"
    if isPositionOpen == false {
        var randomDecision = Int.random(in: 0...2)
        if randomDecision == 0 {
            decisionType = "Buy"
            positionType = "Buy"
            entryPrice = currentPrice
            isPositionOpen = true
        } else if randomDecision == 1 {
            decisionType = "Sell"
            positionType = "Sell"
            entryPrice = currentPrice
            isPositionOpen = true
        } else {
            decisionType = "Ignore"
        }
    } else {
        var shouldClose = Bool.random()
        if shouldClose == true {
            if positionType == "Buy" {
                decisionType = "Sell"
                income = currentPrice - entryPrice
                
            } else {
                decisionType = "Buy"
                income = entryPrice - currentPrice
            }
            balance += income
            print("\(positionType) FROM = \(String(format: "%.2f", entryPrice)) -> TO = \(String(format: "%.2f", currentPrice)), INCOME = \(String(format: "%.2f", income))")
            isPositionOpen = false
        } else {
            decisionType = "Ignore"
        }
    }
    print("\(String(format: "%.2f", currentPrice)) \(currency) - \(decisionType)")
}

print("Balance: \(String(format: "%.2f", balance))")
