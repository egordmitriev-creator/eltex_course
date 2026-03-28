//
//  ViewController.swift
//  TradeApp
//
//  Created by egor_dmitriev on 19.03.2026.
//

import UIKit

final class ViewController: UIViewController {
    
    private let tradeStackView = UIStackView()
    private let searchbarStackView = UIStackView()
    private let searchbarTextField = UITextField()
    private let searchbarSearchBtn = UIButton()
    private let searchbarProfileBtn = UIButton()
    private let waluteStackView = UIStackView()
    private let tradeTextViev = UITextView()
    private let scrollView = UIScrollView()
    private let runButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTradeStackView()
        addSearchbarStackView()
        addScrollView()
        addTradeText()
        addRunButton()
        runBot()
    }
}

private extension ViewController {
    func addTradeStackView() {
        let viewBounds = view.bounds
        let width: CGFloat = viewBounds.width - 32
        let height: CGFloat = viewBounds.height - 16 - 52
        let x: CGFloat = 16
        let y: CGFloat = 52
        tradeStackView.axis = .vertical
        tradeStackView.frame = CGRect(x: x, y: y, width: width, height: height)
        tradeStackView.spacing = 8
        view.addSubview(tradeStackView)
        tradeStackView.addArrangedSubview(searchbarStackView)
        tradeStackView.addArrangedSubview(scrollView)
        tradeStackView.addArrangedSubview(runButton)
    }
    
    func runBot() {
        let bot = AICurrencyBot(
            initialBalance: 1000.0,
            iterations: 20,
            currency: "USD",
            minPrice: 20.0,
            maxPrice: 150.0
        )
        let result = bot.startTrading()
        tradeTextViev.text = result
    }
    
    func addSearchbarStackView() {
        searchbarStackView.axis = .horizontal
        searchbarStackView.spacing = 8.0
        searchbarStackView.backgroundColor = .secondarySystemBackground
        searchbarStackView.translatesAutoresizingMaskIntoConstraints = false
        searchbarStackView.isLayoutMarginsRelativeArrangement = true
        searchbarStackView.layoutMargins = UIEdgeInsets(top: 10, left: 12, bottom: 12, right: 12)
        searchbarStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        
        searchbarTextField.layer.cornerRadius = 4
        searchbarTextField.backgroundColor = .systemBackground
        searchbarTextField.placeholder = " Поиск"
        
        searchbarSearchBtn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchbarSearchBtn.tintColor = .lightGray
        
        searchbarProfileBtn.setImage(UIImage(systemName: "person"), for: .normal)
        searchbarProfileBtn.tintColor = .lightGray
        
        searchbarStackView.addArrangedSubview(searchbarTextField)
        searchbarStackView.addArrangedSubview(searchbarSearchBtn)
        searchbarStackView.addArrangedSubview(searchbarProfileBtn)
    }
    
    func addScrollView() {
        scrollView.addSubview(tradeTextViev)
    }
    
    func addTradeText() {
        let viewBounds = view.bounds
        let width: CGFloat = viewBounds.width - 32
        let height: CGFloat = viewBounds.height / 2
        let x: CGFloat = 0
        let y: CGFloat = 0
        tradeTextViev.backgroundColor = .secondarySystemBackground
        tradeTextViev.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    @objc func handleButtonTapped() {
        runBot()
    }
    
    func addRunButton() {
        let viewBounds = view.bounds
        let width: CGFloat = viewBounds.width
        let height: CGFloat = 32
        let x: CGFloat = 0
        let y: CGFloat = viewBounds.height - height
        runButton.frame = CGRect(x: x, y: y, width: width, height: height)
        runButton.backgroundColor = .systemRed
        runButton.setTitle("RUN!!!", for: .normal)
        runButton.setTitleColor(.black, for: .normal)
        runButton.layer.cornerRadius = height / 2
        runButton.addTarget(self, action: #selector(handleButtonTapped), for: .touchUpInside)
    }
}


