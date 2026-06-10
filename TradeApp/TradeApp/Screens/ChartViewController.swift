//
//  ChartViewController.swift
//  TradeApp
//
//  Created by egor_dmitriev on 10.04.2026.
//

import UIKit

// MARK: Candle struct
struct Candle {
    let open: Double
    let close: Double
    let high: Double
    let low: Double
    
    var isBullish: Bool {
        close >= open
    }
}

// MARK: Main class
final class ChartViewController: UIViewController {
    private let layout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 30, height: 200)
        layout.minimumLineSpacing = 8
        
        return layout
    }()
    
    private let chartSwitch: UISegmentedControl = {
        let control = UISegmentedControl(
            items: [
                UIImage(systemName: "chart.bar.xaxis") ?? UIImage(),
                UIImage(systemName: "chart.line.uptrend.xyaxis") ?? UIImage()
            ]
        )
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    
    private let infoLabel = UILabel()
    private let recomendationLabel = UILabel()
    private let lineChartView = LineChartView()
    
    private var candles: [Candle] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupSubviews()
        setupConstraints()
        generateCandles()
        setupGestures()
        
        chartSwitch.addTarget(self, action: #selector(chartTypeChanged), for: .valueChanged)
            
        updateChartVisibility()
    }
}

// MARK: Setup view
private extension ChartViewController {
    func setupViews() {
        setupCollectionView()
        setupInfoLabel()
        setupRecomendationLabel()
    }
    
    func setupSubviews() {
        view.addSubview(chartSwitch)
        view.addSubview(collectionView)
        view.addSubview(lineChartView)
        view.addSubview(infoLabel)
        view.addSubview(recomendationLabel)
    }
    
    func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        recomendationLabel.translatesAutoresizingMaskIntoConstraints = false
        chartSwitch.translatesAutoresizingMaskIntoConstraints = false
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chartSwitch.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            chartSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: chartSwitch.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 200),
            
            lineChartView.topAnchor.constraint(equalTo: chartSwitch.bottomAnchor, constant: 8),
            lineChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            lineChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            lineChartView.heightAnchor.constraint(equalToConstant: 200),
            
            infoLabel.topAnchor.constraint(equalTo: lineChartView.bottomAnchor, constant: 16),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            recomendationLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 16),
            recomendationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func setupCollectionView() {
        collectionView.register(CandleCell.self, forCellWithReuseIdentifier: CandleCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setupInfoLabel() {
        infoLabel.numberOfLines = 0
    }
    
    func setupRecomendationLabel() {
        recomendationLabel.font = .boldSystemFont(ofSize: 18)
        recomendationLabel.textAlignment = .center
    }
}

// MARK: Generate candles
private extension ChartViewController {
    func generateCandles() {
        candles = (0..<52).map { _ in
            let open = Double.random(in: 50...150)
            let close = open + Double.random(in: -30...30)
            let high = max(open, close) + Double.random(in: 0...20)
            let low = min(open, close) - Double.random(in: 0...20)
            
            return Candle(open: open, close: close, high: high, low: low)
        }
        
        let prices = candles.map { $0.close }
        lineChartView.prices = prices
        
        collectionView.reloadData()
    }
}

// MARK: Touch processing
private extension ChartViewController {
    func setupGestures() {
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTap))
        collectionView.addGestureRecognizer(longTap)
    }
    
    @objc func handleLongTap(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: point),
              gesture.state == .began else { return }
        
        let actions = ["BUY", "SELL", "WAIT"]
        recomendationLabel.text = actions.randomElement()
    }
}
// MARK: DataSource and delegate
extension ChartViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        candles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CandleCell.identifier,
            for: indexPath
        ) as? CandleCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: candles[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let c = candles[indexPath.item]
        
        infoLabel.text = """
        Open: \(String(format: "%.2f", c.open))
        Close: \(String(format: "%.2f", c.close))
        High: \(String(format: "%.2f", c.high))
        Low: \(String(format: "%.2f", c.low))
        """
    }
}

// MARK: func for linear chart
private extension ChartViewController {
    @objc private func chartTypeChanged() {
        updateChartVisibility()
    }
    
    private func updateChartVisibility() {
        let isCandle = chartSwitch.selectedSegmentIndex == 0
        
        collectionView.isHidden = !isCandle
        lineChartView.isHidden = isCandle
    }
}

