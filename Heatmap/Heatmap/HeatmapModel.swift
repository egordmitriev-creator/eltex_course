//
//  HeatmapModel.swift
//  Heatmap
//
//  Created by egor_dmitriev on 26.05.2026.
//

import SwiftUI

// MARK: - Model
struct CryptoAsset: Identifiable {
    let id = UUID()
    let symbol: String
    let price: String
    let changePercent: Double
    let weight: Double

    var color: Color {
        switch changePercent {
        case let x where x >=  5: return Color(red: 0.0,  green: 0.70, blue: 0.33)
        case let x where x >=  1: return Color(red: 0.04, green: 0.50, blue: 0.25)
        case let x where x >= -1: return Color(red: 0.18, green: 0.20, blue: 0.24)
        case let x where x >= -5: return Color(red: 0.65, green: 0.08, blue: 0.08)
        default: return Color(red: 0.85, green: 0.05, blue: 0.05)
        }
    }

    var changeLabel: String {
        String(format: "%@%.2f%%", changePercent >= 0 ? "+" : "", changePercent)
    }
}

// MARK: - Valutes
let assets: [CryptoAsset] = [
    .init(symbol: "BTC",   price: "$67,420", changePercent:  3.24, weight: 28),
    .init(symbol: "ETH",   price: "$3,512",  changePercent: -1.85, weight: 18),
    .init(symbol: "BNB",   price: "$598",    changePercent:  0.72, weight: 9),
    .init(symbol: "SOL",   price: "$178",    changePercent:  6.41, weight: 8),
    .init(symbol: "XRP",   price: "$0.62",   changePercent: -3.17, weight: 7),
    .init(symbol: "ADA",   price: "$0.48",   changePercent:  1.05, weight: 5),
    .init(symbol: "AVAX",  price: "$38.4",   changePercent: -7.60, weight: 5),
    .init(symbol: "DOGE",  price: "$0.165",  changePercent:  8.93, weight: 4),
    .init(symbol: "DOT",   price: "$9.12",   changePercent: -0.44, weight: 4),
    .init(symbol: "MATIC", price: "$0.92",   changePercent:  2.38, weight: 3),
    .init(symbol: "LINK",  price: "$18.7",   changePercent: -2.91, weight: 3),
    .init(symbol: "LTC",   price: "$94.5",   changePercent:  0.58, weight: 2),
]

// MARK: - Treemap Layout
struct TileFrame: Identifiable {
    let id: UUID
    let rect: CGRect
    let asset: CryptoAsset
}

func treemapLayout(assets: [CryptoAsset], in bounds: CGRect) -> [TileFrame] {
    guard !assets.isEmpty else { return [] }
    var result: [TileFrame] = []
    layout(items: assets.sorted { $0.weight > $1.weight }, bounds: bounds, result: &result)
    return result
}

private func layout(items: [CryptoAsset], bounds: CGRect, result: inout [TileFrame]) {
    guard !items.isEmpty else { return }
    guard items.count > 1 else {
        result.append(TileFrame(id: items[0].id, rect: bounds, asset: items[0]))
        return
    }

    let totalWeight = items.map(\.weight).reduce(0, +)
    let area = Double(bounds.width * bounds.height)
    let shortSide = Double(min(bounds.width, bounds.height))
    let horizontal = bounds.width >= bounds.height

    var rowItems: [CryptoAsset] = []
    var rowWeight = 0.0
    var bestRatio = Double.infinity

    for item in items {
        let newWeight = rowWeight + item.weight
        let thickness = ((newWeight / totalWeight) * area) / shortSide
        var worst = 0.0
        for r in rowItems + [item] {
            let len = ((r.weight / totalWeight) * area) / thickness
            worst = max(worst, max(thickness / len, len / thickness))
        }
        if worst < bestRatio {
            bestRatio = worst; rowItems.append(item); rowWeight = newWeight
        } else { break }
    }

    let thickness = CGFloat(((rowWeight / totalWeight) * area) / shortSide)
    var offset = CGFloat.zero
    for item in rowItems {
        let len = CGFloat(item.weight / rowWeight) * (horizontal ? bounds.height : bounds.width)
        let rect: CGRect = horizontal
            ? CGRect(x: bounds.minX,          y: bounds.minY + offset, width: thickness, height: len)
            : CGRect(x: bounds.minX + offset, y: bounds.minY,          width: len,       height: thickness)
        result.append(TileFrame(id: item.id, rect: rect, asset: item))
        offset += len
    }

    let placed = Set(rowItems.map(\.id))
    let remaining = items.filter { !placed.contains($0.id) }
    let next: CGRect = horizontal
        ? CGRect(x: bounds.minX + thickness, y: bounds.minY, width: bounds.width - thickness, height: bounds.height)
        : CGRect(x: bounds.minX, y: bounds.minY + thickness, width: bounds.width, height: bounds.height - thickness)
    layout(items: remaining, bounds: next, result: &result)
}
