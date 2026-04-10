//
//  CurrenciesDetailViewController.swift
//  TradeApp
//
//  Created by egor_dmitriev on 10.04.2026.
//

import Foundation
import UIKit

final class CurrenciesDetailViewController: UIViewController {
    
    private let tableView = UITableView()
    private let allButton = UIButton()
    
    private let dataProvider = CurrenciesDataProviderService.shared
    private var shortList: [Currency] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupUI()
        generateShortList()
    }
}

private extension CurrenciesDetailViewController {
    func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        allButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        view.addSubview(allButton)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        allButton.setTitle("All", for: .normal)
        allButton.setTitleColor(.systemBlue, for: .normal)
        allButton.addTarget(self, action: #selector(openFullList), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            allButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            allButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: allButton.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

private extension CurrenciesDetailViewController {
    func generateShortList() {
        let favorites = dataProvider.currencies.filter { _ in 
            dataProvider.isFavoritesEnabled && true
        }
        
        if !favorites.isEmpty {
            shortList = Array(favorites.prefix(10))
        } else {
            shortList = Array(dataProvider.currencies.shuffled().prefix(10))
        }
        
        tableView.reloadData()
    }
}

extension CurrenciesDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shortList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let currency = shortList[indexPath.row]
        cell.textLabel?.text = currency.code
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currency = shortList[indexPath.row]
        dataProvider.selectCurrency(currency)
        dismiss(animated: true)
    }
}


private extension CurrenciesDetailViewController {
    @objc func openFullList() {
        let vc = CurrenciesViewController()
        vc.title = "All currencies"
        navigationController?.pushViewController(vc, animated: true)
    }
}
