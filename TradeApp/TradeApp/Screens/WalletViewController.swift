//
//  WalletViewController.swift
//  TradeApp
//
//  Created by egor_dmitriev on 25.04.2026.
//

import Foundation
import UIKit

import UIKit

final class WalletViewController: UIViewController {
    private let tableView = UITableView()
    private var balanceData: [(String, Double)] = []
    private var creditData: [(String, Double)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupNav()
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    private func setupNav() {
        title = "Wallet"
        
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupUI() {
        tableView.frame = view.bounds
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
    private func reloadData() {
        let wallet = BotManager.shared.wallet
        
        let snapshot = wallet.snapshot()
        let credit = wallet.creditInfo()
        
        balanceData = snapshot.map { ($0.key, $0.value) }
        creditData = credit.map { ($0.key, $0.value) }
        
        tableView.reloadData()
    }
    
    @objc private func backTapped() {
        dismiss(animated: true)
    }
}

extension WalletViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return balanceData.count
        default: return creditData.count
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        
        switch indexPath.section {
        case 0:
            let item = balanceData[indexPath.row]
            cell.textLabel?.text = "Balance: \(item.0)"
            cell.detailTextLabel?.text = String(format: "%.2f", item.1)
            
        default:
            let item = creditData[indexPath.row]
            cell.textLabel?.text = "Credit: \(item.0)"
            cell.detailTextLabel?.text = String(format: "%.2f", item.1)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Balances"
        default: return "Credit (refill history)"
        }
    }
}
