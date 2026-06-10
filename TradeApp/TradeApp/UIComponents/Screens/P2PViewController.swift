//
//  P2PViewController.swift
//  TradeApp
//
//  Created by egor_dmitriev on 26.04.2026.
//

import Foundation
import UIKit
 
final class P2PViewController: UIViewController {
    // MARK: UI
    private let walletLabel = UILabel()
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
 
    // MARK: Dependencies
    private let viewModel: P2PViewModel
 
    // MARK: Init
    init(viewModel: P2PViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
 
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
 
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNav()
        bindViewModel()
        viewModel.viewDidLoad()
    }
 
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "P2P"
 
        walletLabel.translatesAutoresizingMaskIntoConstraints = false
        walletLabel.font = .systemFont(ofSize: 14, weight: .medium)
        walletLabel.textAlignment = .center
        walletLabel.textColor = .secondaryLabel
 
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(P2POfferCell.self, forCellReuseIdentifier: P2POfferCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
 
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
 
        view.addSubview(walletLabel)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
 
        NSLayoutConstraint.activate([
            walletLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            walletLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            walletLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
 
            tableView.topAnchor.constraint(equalTo: walletLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
 
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
 
    private func setupNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
    }
 
    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onOffersUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
 
        viewModel.onWalletUpdated = { [weak self] text in
            self?.walletLabel.text = text
        }
 
        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
 
        viewModel.onLoadingChanged = { [weak self] isLoading in
            isLoading ? self?.activityIndicator.startAnimating()
                      : self?.activityIndicator.stopAnimating()
            self?.tableView.isUserInteractionEnabled = !isLoading
        }
    }
 
    // MARK: - Actions
    @objc private func backTapped() {
        viewModel.didTapBack()
    }
 
    // MARK: - Helpers
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
 
    private func showTradeAlert(for index: Int) {
        let offer = viewModel.offers[index]
        let alert = UIAlertController(
            title: "Сделка с \(offer.sellerName)",
            message: "Курс: \(offer.rateFormatted)\nРезерв: \(offer.reserveFormatted)\n\nВведите сумму:",
            preferredStyle: .alert
        )
        alert.addTextField { tf in
            tf.keyboardType = .decimalPad
            tf.placeholder = "0.00"
        }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Обмен", style: .default) { [weak self] _ in
            self?.viewModel.didSelectOffer(at: index, amountText: alert.textFields?.first?.text)
        })
        present(alert, animated: true)
    }
}
 
// MARK: - UITableViewDataSource
extension P2PViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.offers.count
    }
 
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: P2POfferCell.identifier,
            for: indexPath
        ) as! P2POfferCell
 
        cell.configure(with: viewModel.offers[indexPath.row])
        cell.onInfoTapped = { [weak self] in
            self?.viewModel.didTapSellerInfo(at: indexPath.row)
        }
        return cell
    }
}
 
// MARK: - UITableViewDelegate
extension P2PViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showTradeAlert(for: indexPath.row)
    }
}
