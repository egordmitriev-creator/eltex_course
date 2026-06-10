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
    private let gridLayer = CAShapeLayer()
    
    private let indicatorLayer = CAShapeLayer()
    private let pointLayer = CAShapeLayer()
    private let priceIndicatorLabel = UILabel()
    
    private var priceLabels: [UILabel] = []
    
    private var maxPrice: Double = .zero
    private var minPrice: Double = .zero
    
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
        drawGrid(max: maxPrice, min: minPrice)
    }
}


// MARK: View
private extension LineChartView {
    func setupLayer() {
        setupViews()
        setupSubviews()
    }
    
    func setupSubviews() {
        layer.addSublayer(gridLayer)
        layer.addSublayer(shapeLayer)
        layer.addSublayer(indicatorLayer)
        layer.addSublayer(pointLayer)
    }

    func setupViews() {
        shapeLayer.strokeColor = UIColor.systemBlue.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        
        priceIndicatorLabel.font = .systemFont(ofSize: 12)
        priceIndicatorLabel.textColor = .black
        addSubview(priceIndicatorLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
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
    
    func drawGrid(max: Double, min: Double) {
        gridLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        gridLayer.path = nil
        
        priceLabels.forEach { $0.removeFromSuperview() }
        priceLabels.removeAll()
        
        let path = UIBezierPath()
        
        let steps = 5
        let range = max - min == 0 ? 1 : max - min
        
        for i in 0..<steps {
            let percent = CGFloat(i) / CGFloat(steps - 1)
            let price = min + Double(percent) * range
            
            let y = bounds.height * (1 - percent)
            
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: bounds.width, y: y))
            
            // label
            let label = UILabel()
            label.font = .systemFont(ofSize: 10)
            label.textColor = .gray
            label.text = String(format: "%.1f", price)
            label.frame = CGRect(x: 0, y: y - 8, width: 50, height: 16)
            
            addSubview(label)
            priceLabels.append(label)
        }
        
        let verticalSteps = 6
        
        for i in 0..<verticalSteps {
            let x = bounds.width * CGFloat(i) / CGFloat(verticalSteps - 1)
            
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: bounds.height))
        }
        
        gridLayer.path = path.cgPath
        gridLayer.strokeColor = UIColor.lightGray.cgColor
        gridLayer.lineWidth = 0.5
    }
    
    @objc
    func handleTap(_ gesture: UITapGestureRecognizer) {
        guard prices.count > 1 else { return }
        
        let location = gesture.location(in: self)
        
        let stepX = bounds.width / CGFloat(prices.count - 1)
        
        let index = Int(round(location.x / stepX))
        let safeIndex = max(0, min(index, prices.count - 1))
        
        let price = prices[safeIndex]
        
        let maxPrice = prices.max() ?? 0
        let minPrice = prices.min() ?? 0
        let range = maxPrice - minPrice == 0 ? 1 : maxPrice - minPrice
        
        let x = CGFloat(safeIndex) * stepX
        let y = bounds.height * (1 - CGFloat((price - minPrice) / range))
        
        drawIndicator(x: x, y: y, price: price)
    }
    
    func drawIndicator(x: CGFloat, y: CGFloat, price: Double) {
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: x, y: 0))
        linePath.addLine(to: CGPoint(x: x, y: bounds.height))
        
        indicatorLayer.path = linePath.cgPath
        indicatorLayer.strokeColor = UIColor.gray.cgColor
        indicatorLayer.lineWidth = 1
        
        let pointPath = UIBezierPath(arcCenter: CGPoint(x: x, y: y),
                                     radius: 4,
                                     startAngle: 0,
                                     endAngle: .pi * 2,
                                     clockwise: true)
        
        pointLayer.path = pointPath.cgPath
        pointLayer.fillColor = UIColor.red.cgColor
        
        priceIndicatorLabel.text = String(format: "%.2f", price)
        priceIndicatorLabel.sizeToFit()
        
        priceIndicatorLabel.frame.origin = CGPoint(
            x: min(x + 5, bounds.width - priceIndicatorLabel.frame.width),
            y: max(y - 20, 0)
        )
    }
}
