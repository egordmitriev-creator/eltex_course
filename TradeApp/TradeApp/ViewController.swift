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
    private let runButton = UIButton()
    private let emptyLabel = UILabel()
    private let tableView: UITableView = UITableView()
    
    private var data: [TradeMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
    }
}

// MARK: - Setup
private extension ViewController {
    func setupViews() {
        view.backgroundColor = .systemBackground
        
        setupTradeStackView()
        setupSearchBar()
        setupTabelView()
        setupRunButton()
        setupEmptyLabel()
    }
    
    func setupTradeStackView() {
        tradeStackView.axis = .vertical
        tradeStackView.spacing = 8
        tradeStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tradeStackView)
        
        tradeStackView.addArrangedSubview(searchbarStackView)
        tradeStackView.addArrangedSubview(tableView)
        tradeStackView.addArrangedSubview(runButton)
        
        runButton.setContentHuggingPriority(.required, for: .vertical)
    }
    
    func setupSearchBar() {
        searchbarStackView.axis = .horizontal
        searchbarStackView.spacing = 8
        searchbarStackView.backgroundColor = .secondarySystemBackground
        searchbarStackView.translatesAutoresizingMaskIntoConstraints = false
        searchbarStackView.isLayoutMarginsRelativeArrangement = true
        searchbarStackView.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        searchbarTextField.backgroundColor = .systemBackground
        searchbarTextField.layer.cornerRadius = 6
        searchbarTextField.placeholder = " Поиск"
        
        searchbarSearchBtn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchbarSearchBtn.tintColor = .lightGray
        
        searchbarProfileBtn.setImage(UIImage(systemName: "person"), for: .normal)
        searchbarProfileBtn.tintColor = .lightGray
        
        searchbarStackView.addArrangedSubview(searchbarTextField)
        searchbarStackView.addArrangedSubview(searchbarSearchBtn)
        searchbarStackView.addArrangedSubview(searchbarProfileBtn)
        
        searchbarSearchBtn.translatesAutoresizingMaskIntoConstraints = false
        searchbarProfileBtn.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupTabelView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TradeCell.self, forCellReuseIdentifier: TradeCell.identifier)
        
        tableView.dataSource = self
        
        tableView.backgroundColor = .secondarySystemBackground
    }
    
    func setupRunButton() {
        runButton.translatesAutoresizingMaskIntoConstraints = false
        runButton.backgroundColor = .systemRed
        runButton.setTitle("RUN!!!", for: .normal)
        runButton.setTitleColor(.black, for: .normal)
        runButton.layer.cornerRadius = 16
        
        runButton.addTarget(self, action: #selector(handleButtonTapped), for: .touchUpInside)
    }
    
    func setupEmptyLabel() {
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "Нет данных"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .gray
        emptyLabel.font = .systemFont(ofSize: 18, weight: .medium)
        
        view.addSubview(emptyLabel)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TradeCell.identifier, for: indexPath) as! TradeCell
        cell.currentMessage = data[indexPath.row]
        
        return cell
    }
}

// MARK: - Constraints
private extension ViewController {
    func setupConstraints() {
        let constraints = [
            // tradeStackView
            NSLayoutConstraint(item: tradeStackView, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: tradeStackView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 16),
            NSLayoutConstraint(item: tradeStackView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -16),
            NSLayoutConstraint(item: tradeStackView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: -8),
            
            // searchbar height
            NSLayoutConstraint(item: searchbarStackView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60),
            
            // searchbar buttons
            NSLayoutConstraint(item: searchbarSearchBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: searchbarProfileBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30),
            
            // run button height
            NSLayoutConstraint(item: runButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 32),
            
            // emptyLabel
            NSLayoutConstraint(item: emptyLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: emptyLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - Logic
private extension ViewController {
    @objc func handleButtonTapped() {
        runBot()
    }
    
    func runBot() {
        let bot = AICurrencyBot(
            initialBalance: 1000.0,
            iterations: 30,
            currency: "USD",
            minPrice: 20.0,
            maxPrice: 150.0
        )
        
        data = bot.startTrading()
        
        tableView.reloadData()
        emptyLabel.isHidden = !data.isEmpty
    }
}
