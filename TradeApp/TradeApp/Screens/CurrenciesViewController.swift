//
//  CurrenciesViewController.swift
//  TradeApp
//
//  Created by egor_dmitriev on 02.04.2026.
//

import UIKit

final class CurrenciesViewController: UIViewController{
    // MARK: - UI
    private let layout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 75, height: 40)
        
        return layout
    }()
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    
    private let curencyButtonsStack = UIStackView()
    private let firstCurrencyBtn = UIButton()
    private let secondCurrencyBtn = UIButton()
    private let rateLabel = UILabel()
    private let filterSegment = UISegmentedControl(items: ["Все", "Фиат", "Крипта"])
    private let inputField = UITextField()
    private let resultLabel = UILabel()
    private let timerLabel = UILabel()
    private let favoritesView = FavoritesView()
    private let emptyLabel = UILabel()
    
    // MARK: - Data
    private let dataProvider = CurrenciesDataProviderService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollection()
        setupUI()
        setutSubviews()
        setupConstraints()
        
        dataProvider.onCurrencyChange = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
                self?.collectionView.reloadData()
            }
        }
        
        updateUI()
        startTimer()
    }
}

// MARK: - Setup
private extension CurrenciesViewController {
    func setupCollection() {
        collectionView.register(CurrencyCell.self, forCellWithReuseIdentifier: CurrencyCell.identifier)
        collectionView.dataSource = dataProvider
        collectionView.delegate = dataProvider
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        curencyButtonsStack.axis = .horizontal
        curencyButtonsStack.spacing = 8
        
        firstCurrencyBtn.addTarget(self, action: #selector(selectFirst), for: .touchUpInside)
        secondCurrencyBtn.addTarget(self, action: #selector(selectSecond), for: .touchUpInside)
        firstCurrencyBtn.backgroundColor = .secondarySystemBackground
        secondCurrencyBtn.backgroundColor = .secondarySystemBackground
        firstCurrencyBtn.layer.cornerRadius = 8
        secondCurrencyBtn.layer.cornerRadius = 8
        filterSegment.selectedSegmentIndex = 0
        filterSegment.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        inputField.placeholder = "Сумма"
        inputField.borderStyle = .roundedRect
        inputField.keyboardType = .decimalPad
        inputField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)
        resultLabel.text = "0"
        timerLabel.textAlignment = .center
        
        favoritesView.delegate = self
        
        emptyLabel.text = "Нет избранных валют"
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
    }
    
    func setutSubviews() {
        [curencyButtonsStack, rateLabel, filterSegment, collectionView, inputField, resultLabel, timerLabel, favoritesView, emptyLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        curencyButtonsStack.addArrangedSubview(firstCurrencyBtn)
        curencyButtonsStack.addArrangedSubview(secondCurrencyBtn)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            curencyButtonsStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            curencyButtonsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            rateLabel.topAnchor.constraint(equalTo: curencyButtonsStack.bottomAnchor, constant: 8),
            rateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            filterSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            inputField.topAnchor.constraint(equalTo: filterSegment.bottomAnchor, constant: 8),
            inputField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            resultLabel.topAnchor.constraint(equalTo: inputField.bottomAnchor, constant: 8),
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            timerLabel.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 4),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            favoritesView.topAnchor.constraint(equalTo: rateLabel.bottomAnchor, constant: 8),
            favoritesView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            favoritesView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            favoritesView.heightAnchor.constraint(equalToConstant: 40),

            filterSegment.topAnchor.constraint(equalTo: favoritesView.bottomAnchor, constant: 8),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
        
        firstCurrencyBtn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        secondCurrencyBtn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        firstCurrencyBtn.widthAnchor.constraint(equalToConstant: 120).isActive = true
        secondCurrencyBtn.widthAnchor.constraint(equalToConstant: 120).isActive = true
    }
}

// MARK: - Actions
private extension CurrenciesViewController {
    @objc func selectFirst() {
        dataProvider.selectingSide = .first
        updateUI()
    }
    
    @objc func selectSecond() {
        dataProvider.selectingSide = .second
        updateUI()
    }
    
    @objc func filterChanged() {
        dataProvider.applyFilter(filterIndex: filterSegment.selectedSegmentIndex)
        collectionView.reloadData()
    }
    
    @objc func amountChanged() {
        updateResult()
    }
}

// MARK: - UI Updates
private extension CurrenciesViewController {
    func updateUI() {
        let firstCode = dataProvider.selectedFirst?.code ?? "-"
        let secondCode = dataProvider.selectedSecond?.code ?? "-"
        
        firstCurrencyBtn.setTitle(firstCode, for: .normal)
        secondCurrencyBtn.setTitle(secondCode, for: .normal)
        firstCurrencyBtn.setTitleColor(dataProvider.selectingSide == .first ? .systemBlue : .label, for: .normal)
        secondCurrencyBtn.setTitleColor(dataProvider.selectingSide == .second ? .systemBlue : .label, for: .normal)
        updateRateLabel()
        
        emptyLabel.isHidden = !dataProvider.filteredCurrencies.isEmpty
        collectionView.isHidden = dataProvider.filteredCurrencies.isEmpty
    }
    
    func updateRateLabel() {
        let firstCode = dataProvider.selectedFirst?.code ?? "-"
        let secondCode = dataProvider.selectedSecond?.code ?? "-"
        
        rateLabel.text = "1 \(firstCode) = \(String(format: "%.4f", dataProvider.rate)) \(secondCode)"
        updateResult()
    }
    
    func updateResult() {
        guard let text = inputField.text, let amount = Double(text) else {
            resultLabel.text = "0"
            return
        }
        let result = dataProvider.calculateResult(amount: amount)
        let secondCode = dataProvider.selectedSecond?.code ?? "-"
        resultLabel.text = "\(String(format: "%.4f", result)) \(secondCode)"
    }
    
    func startTimer() {
        dataProvider.startTimer(update: { [weak self] seconds in
            self?.timerLabel.text = "Обновление через: \(seconds)"
        }, onRateUpdate: { [weak self] in
            self?.updateRateLabel()
        })
    }
}

extension CurrenciesViewController: FavoritesViewDelegate{
    func didToggleFavorite(isOn: Bool) {
        dataProvider.isFavoritesEnabled = isOn
        dataProvider.applyCurrentFilters()
        collectionView.reloadData()
    }
}
