//
//  P2PViewController.swift
//  TradeApp
//
//  Created by egor_dmitriev on 26.04.2026.
//

import Foundation
import UIKit

final class P2PViewController: UIViewController {
    
    private let tableView = UITableView()
    private var offers: [P2POffer] = []
    
    private let dataProvider = CurrenciesDataProviderService.shared
    private let network = NetworkService.shared
    private let service = P2PService()
    
    private let walletLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "P2P"
        
        setupUI()
        setupNav()
        loadData()
        
        dataProvider.addObserver { [weak self] in
            DispatchQueue.main.async {
                self?.loadData()
            }
        }
    }
    
    private func setupUI() {
        walletLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(walletLabel)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            walletLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            walletLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: walletLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadData() {
        guard let base = dataProvider.selectedFirst?.code else { return }
        
        network.fetchRates(base: base) { [weak self] result in
            DispatchQueue.main.async {
                
                switch result {
                case .success(let rates):
                    guard let target = self?.dataProvider.selectedSecond?.code else { return }
                    self?.offers = self?.service.generateOffers(rates: rates, target: target) ?? []
                    self?.tableView.reloadData()
                    self?.updateWallet()
                    
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    
    private func updateWallet() {
        let wallet = BotManager.shared.wallet
        
        let first = dataProvider.selectedFirst?.code ?? ""
        let second = dataProvider.selectedSecond?.code ?? ""
        
        let b1 = wallet.getBalance(first)
        let b2 = wallet.getBalance(second)
        
        walletLabel.text = "\(first): \(String(format: "%.2f", b1)) | \(second): \(String(format: "%.2f", b2))"
    }
    
    private func showError(_ error: NetworkError) {
        let text: String
        
        switch error {
        case .noInternet:
            text = "Нет интернета"
        case .parsingError:
            text = "Ошибка данных"
        case .unauthorized:
            text = "Нет доступа"
        default:
            text = "Ошибка"
        }
        
        let alert = UIAlertController(title: "Ошибка", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension P2PViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        offers.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        let offer = offers[indexPath.row]
        
        cell.textLabel?.text = offer.sellerName
        cell.detailTextLabel?.text = "Rate: \(String(format: "%.4f", offer.rate)) | Reserve: \(String(format: "%.2f", offer.reserve))"
        
        return cell
    }
}

extension P2PViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let offer = offers[indexPath.row]
        
        let alert = UIAlertController(title: "Сделка", message: "Введите сумму", preferredStyle: .alert)
        
        alert.addTextField()
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Обмен", style: .default) { _ in
            
            guard let text = alert.textFields?.first?.text,
                  let amount = Double(text) else {
                self.showSimpleError("Введите корректное число")
                return
            }
            
            guard amount > 0 else {
                self.showSimpleError("Сумма должна быть больше 0")
                return
            }
            
            let wallet = BotManager.shared.wallet
            let base = self.dataProvider.selectedFirst?.code ?? ""
            
            let balance = wallet.getBalance(base)
            
            guard amount <= balance else {
                self.showSimpleError("Недостаточно средств")
                return
            }
            
            NetworkService.shared.performTrade { result in
                DispatchQueue.main.async {
                    
                    switch result {
                    case .success:
                        self.performWalletUpdate(amount: amount, offer: offer)
                    case .failure(let error):
                        self.showError(error)
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    private func performWalletUpdate(amount: Double, offer: P2POffer) {
        let wallet = BotManager.shared.wallet
        
        guard let base = dataProvider.selectedFirst?.code,
              let quote = dataProvider.selectedSecond?.code else { return }
        
        wallet.updateBalance(currency: base, delta: -amount)
        wallet.updateBalance(currency: quote, delta: amount * offer.rate)
        
        updateWallet()
    }
}

private extension P2PViewController {
    func setupNav() {
        let back = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        
        navigationItem.leftBarButtonItem = back
    }
    
    @objc func backTapped() {
        dismiss(animated: true)
    }
    
    func showSimpleError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
