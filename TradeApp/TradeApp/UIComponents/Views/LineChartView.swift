//
//  LineChartView.swift
//  TradeApp
//
//  Created by egor_dmitriev on 19.04.2026.
//

import Foundation
import UIKit

final class LineChartView: UIView {
    
    private let shapeLayer = CAShapeLayer()
    
    var prices: [Double] = [] {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawChart()
    }
}


// MARK: View
private extension LineChartView {
    func setupLayer() {
        setupViews()
        setupSubviews()
    }
    
    func setupSubviews() {
        layer.addSublayer(shapeLayer)
    }

    func setupViews() {
        shapeLayer.strokeColor = UIColor.systemBlue.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
    }
}

// MARK: Logic
private extension LineChartView {
    func drawChart() {
        guard prices.count > 1 else { return }
        
        let path = UIBezierPath()
        
        let maxPrice = prices.max() ?? 0
        let minPrice = prices.min() ?? 0
        let range = maxPrice - minPrice == 0 ? 1 : maxPrice - minPrice
        
        let stepX = bounds.width / CGFloat(prices.count - 1)
        
        for (index, price) in prices.enumerated() {
            let x = CGFloat(index) * stepX
            
            let normalized = (price - minPrice) / range
            let y = bounds.height * (1 - CGFloat(normalized))
            
            let point = CGPoint(x: x, y: y)
            
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        shapeLayer.path = path.cgPath
    }
}
