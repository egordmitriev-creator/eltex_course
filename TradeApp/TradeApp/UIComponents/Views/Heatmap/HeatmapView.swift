//
//  HeatmapView.swift
//  Heatmap
//
//  Created by egor_dmitriev on 26.05.2026.
//

import SwiftUI

// MARK: - Screen
struct HeatmapView: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("Heatmap")
            .font(.system(size: 20, weight: .black, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 14)

            GeometryReader { geo in
                let tiles = treemapLayout(assets: assets, in: CGRect(origin: .zero, size: geo.size))
                ZStack(alignment: .topLeading) {
                    ForEach(tiles) { tile in
                        TileView(asset: tile.asset, size: tile.rect.size)
                            .frame(width: tile.rect.width, height: tile.rect.height)
                            .offset(x: tile.rect.minX, y: tile.rect.minY)
                    }
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Preview
#Preview {
    HeatmapView()
}
