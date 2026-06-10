//
//  CandleCell.swift
//  TradeApp
//
//  Created by egor_dmitriev on 10.04.2026.
//

import UIKit

final class CandleCell: UICollectionViewCell {
    
    static let identifier = "CandleCell"
    
    private let bodyView = UIView()
    private let wickView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(wickView)
        contentView.addSubview(bodyView)
        
        wickView.backgroundColor = .black
        bodyView.layer.cornerRadius = 2
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(with candle: Candle) {
        let color: UIColor = candle.isBullish ? .systemGreen : .systemRed
        bodyView.backgroundColor = color
        wickView.backgroundColor = color
        
        let totalHeight = contentView.bounds.height
        
        let high = CGFloat(candle.high)
        let low = CGFloat(candle.low)
        let open = CGFloat(candle.open)
        let close = CGFloat(candle.close)
        
        let maxPrice = max(high, open, close)
        let minPrice = min(low, open, close)
        
        let range = maxPrice - minPrice + 0.1
        
        let scale = totalHeight / range
        
        let openY = (maxPrice - open) * scale
        let closeY = (maxPrice - close) * scale
        
        let bodyTop = min(openY, closeY)
        let bodyBottom = max(openY, closeY)

        let topWick = CGFloat.random(in: 5...30)
        let bottomWick = CGFloat.random(in: 5...30)

        let wickTop = bodyTop - topWick
        let wickBottom = bodyBottom + bottomWick

        // wick
        wickView.frame = CGRect(
            x: contentView.bounds.midX - 1,
            y: wickTop,
            width: 2,
            height: wickBottom - wickTop
        )
        // body
        bodyView.frame = CGRect(
            x: contentView.bounds.midX - 8,
            y: bodyTop,
            width: 16,
            height: max(bodyBottom - bodyTop, 2)
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bodyView.frame = .zero
        wickView.frame = .zero
    }
}
