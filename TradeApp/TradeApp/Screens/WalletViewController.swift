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
    private var data: [(String, Double)] = []

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
        let snapshot = BotManager.shared.getWalletSnapshot()
        data = snapshot.map { ($0.key, $0.value) }
        tableView.reloadData()
    }
    
    @objc private func backTapped() {
        dismiss(animated: true)
    }
}

extension WalletViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        
        let item = data[indexPath.row]
        cell.textLabel?.text = item.0
        cell.detailTextLabel?.text = String(format: "%.2f", item.1)
        
        return cell
    }
}
