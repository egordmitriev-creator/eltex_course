//
//  TradeViewController.swift
//  TradeApp
//
//  Created by egor_dmitriev on 19.03.2026.
//

import UIKit

final class TradeViewController: UIViewController {
    private let tradeStackView = UIStackView()
    private let searchbarStackView = UIStackView()
    private let searchbarTextField = UITextField()
    private let searchbarSearchBtn = UIButton()
    private let searchbarProfileBtn = UIButton()
    private let runButton = UIButton()
    private let emptyLabel = UILabel()
    private let tableView: UITableView = UITableView()
    
    private let pairView = UIStackView()
    private let firstCurrencyLabel = UILabel()
    private let secondCurrencyLabel = UILabel()
    
    private let dataProvider = CurrenciesDataProviderService.shared
    
    private var data: [TradeMessage] = []
    
    private var botsCreated = false
    
    private var p2pCoordinator: P2PCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        updatePairUI()
        
        setupSwipe()
        
        dataProvider.addObserver { [weak self] in
            DispatchQueue.main.async {
                self?.updatePairUI()
                self?.resetTrading()
            }
        }
    }
}

// MARK: - Setup
private extension TradeViewController {
    func setupViews() {
        view.backgroundColor = .systemBackground
        
        setupTradeStackView()
        setupSearchBar()
        setupPairView()
        setupTabelView()
        setupRunButton()
        setupEmptyLabel()
        setupSubviews()
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        let resetButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(resetTapped)
        )
        
        let randomButton = UIBarButtonItem(
            image: UIImage(systemName: "shuffle"),
            style: .plain,
            target: self,
            action: #selector(randomTapped)
        )
        
        let walletButton = UIBarButtonItem(
            image: UIImage(systemName: "wallet.pass"),
            style: .plain,
            target: self,
            action: #selector(openWallet)
        )
        
        let p2pButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left.arrow.right"),
            style: .plain,
            target: self,
            action: #selector(openP2P)
        )
        
        navigationItem.leftBarButtonItems = [resetButton, randomButton]
        navigationItem.rightBarButtonItems = [walletButton, p2pButton]
    }
    
    func setupSubviews() {
        view.addSubview(tradeStackView)
        view.addSubview(emptyLabel)
        
        tradeStackView.addArrangedSubview(searchbarStackView)
        
        tradeStackView.addArrangedSubview(pairView)
        
        tradeStackView.addArrangedSubview(tableView)
        tradeStackView.addArrangedSubview(runButton)
        
        searchbarStackView.addArrangedSubview(searchbarTextField)
        searchbarStackView.addArrangedSubview(searchbarSearchBtn)
        searchbarStackView.addArrangedSubview(searchbarProfileBtn)
    }
    
    func setupTradeStackView() {
        tradeStackView.axis = .vertical
        tradeStackView.spacing = 8
        tradeStackView.translatesAutoresizingMaskIntoConstraints = false
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
        searchbarSearchBtn.translatesAutoresizingMaskIntoConstraints = false
        searchbarProfileBtn.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupPairView() {
        pairView.axis = .horizontal
        pairView.spacing = 8
        pairView.alignment = .center
        pairView.backgroundColor = .secondarySystemBackground
        pairView.layer.cornerRadius = 12
        pairView.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        pairView.isLayoutMarginsRelativeArrangement = true
        
        firstCurrencyLabel.font = .boldSystemFont(ofSize: 16)
        secondCurrencyLabel.font = .boldSystemFont(ofSize: 16)
        
        pairView.addArrangedSubview(firstCurrencyLabel)
        pairView.addArrangedSubview(secondCurrencyLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(pairTapped))
        pairView.addGestureRecognizer(tap)
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
        runButton.layer.cornerRadius = 16
        runButton.setContentHuggingPriority(.required, for: .vertical)
        runButton.addTarget(self, action: #selector(handleButtonTapped), for: .touchUpInside)
    }
    
    func setupEmptyLabel() {
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "Нет данных"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .gray
        emptyLabel.font = .systemFont(ofSize: 18, weight: .medium)
    }
}

extension TradeViewController: UITableViewDataSource {
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
private extension TradeViewController {
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
private extension TradeViewController {
    @objc func handleButtonTapped() {
        runBot()
    }
    
    func runBot() {
        if !botsCreated {
            let bot1 = AICurrencyBot(name: "BotA", pair: "BTC-USD")
            let bot2 = AICurrencyBot(name: "BotB", pair: "RUB-ETH")
            let bot3 = AICurrencyBot(name: "BotC", pair: "BTC-RUB")
            
            BotManager.shared.register(bot: bot1)
            BotManager.shared.register(bot: bot2)
            BotManager.shared.register(bot: bot3)
            
            botsCreated = true
        }
        
        let results = BotManager.shared.runAllBots()
        
        data = results.map {
            let income = $0.income
            
            let color: UIColor = {
                if income > 0 {
                    return .systemGreen
                } else if income < 0 {
                    return .systemRed
                } else {
                    return .label
                }
            }()
            
            return TradeMessage(
                id: UUID(),
                text: "\($0.botName) (\($0.pair)), day = \($0.day), income = \(String(format: "%.2f", income))",
                details: nil,
                color: color
            )
        }
        
        tableView.reloadData()
        emptyLabel.isHidden = !data.isEmpty
    }
    
    func updatePairUI() {
        firstCurrencyLabel.text = dataProvider.selectedFirst?.code ?? "-"
        secondCurrencyLabel.text = dataProvider.selectedSecond?.code ?? "-"
    }
    
    func resetTrading() {
        data.removeAll()
        tableView.reloadData()
        emptyLabel.isHidden = false
    }
    
    @objc func pairTapped() {
        let vc = CurrenciesDetailViewController()
        vc.title = "Select currency"
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        
        present(nav, animated: true)
    }
    
    @objc func resetTapped() {
        resetTrading()
    }
    
    @objc func randomTapped() {
        dataProvider.selectRandomPair()
    }
}

private extension TradeViewController {
    func setupSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp))
        swipe.direction = .up
        
        view.addGestureRecognizer(swipe)
    }
    
    @objc private func handleSwipeUp() {
        tabBarController?.selectedIndex = 2
    }
}

private extension TradeViewController {
    @objc func openWallet() {
        let vc = WalletViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    @objc func openP2P() {
        let coordinator = P2PCoordinator(presentingViewController: self)
        p2pCoordinator = coordinator
        let nav = coordinator.start()
        present(nav, animated: true)
    }
}
