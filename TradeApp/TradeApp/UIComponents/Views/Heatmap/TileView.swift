//
//  TileView.swift
//  Heatmap
//
//  Created by egor_dmitriev on 26.05.2026.
//

import SwiftUI

struct TileView: View {
    let asset: CryptoAsset
    let size: CGSize

    private var isSmall: Bool { size.width < 70 || size.height < 55 }
    private var isTiny:  Bool { size.width < 46 || size.height < 38 }

    var body: some View {
        ZStack {
            asset.color
            if !isTiny {
                VStack(spacing: 2) {
                    Text(asset.symbol)
                        .font(.system(size: isSmall ? 12 : 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    if !isSmall {
                        Text(asset.price)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.75))
                    }
                    Text(asset.changeLabel)
                        .font(.system(size: isSmall ? 9 : 12, weight: .semibold, design: .rounded))
                        .foregroundColor(asset.changePercent >= 0
                            ? Color(red: 0.6, green: 1.0, blue: 0.7)
                            : Color(red: 1.0, green: 0.6, blue: 0.6))
                }
            }
        }
        .border(Color.black.opacity(0.45), width: 1)
    }
}
