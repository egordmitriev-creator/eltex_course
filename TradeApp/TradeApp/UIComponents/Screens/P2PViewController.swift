//
//  P2PViewController.swift
//  TradeApp
//
//  Created by egor_dmitriev on 26.04.2026.
//

import Foundation
import UIKit
 
final class P2PViewController: UIViewController {
    // MARK: - UI
    private let walletLabel = UILabel()
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let emptyLabel = UILabel()
 
    // MARK: - Dependencies
    private let viewModel: P2PViewModel
 
    // MARK: - Init
    init(viewModel: P2PViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
 
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
 
    // MARK: - Lifecycle
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
 
        walletLabel.font = .systemFont(ofSize: 14, weight: .medium)
        walletLabel.textAlignment = .center
        walletLabel.textColor = .secondaryLabel
        walletLabel.translatesAutoresizingMaskIntoConstraints = false
 
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(P2POfferCell.self, forCellReuseIdentifier: P2POfferCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.translatesAutoresizingMaskIntoConstraints = false
 
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
 
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emptyLabel.numberOfLines = 0
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
 
        view.addSubview(walletLabel)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyLabel)
 
        NSLayoutConstraint.activate([
            walletLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            walletLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            walletLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
 
            tableView.topAnchor.constraint(equalTo: walletLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
 
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
 
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
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
        viewModel.onStateChanged = { [weak self] state in
            self?.render(state)
        }
 
        viewModel.onWalletUpdated = { [weak self] text in
            self?.walletLabel.text = text
        }
 
        viewModel.onTradeError = { [weak self] message in
            self?.showAlert(title: "Ошибка", message: message)
        }
    }
 
    // MARK: - State rendering
    private func render(_ state: P2PScreenState) {
        switch state {
        case .idle:
            activityIndicator.stopAnimating()
            emptyLabel.isHidden = true
            tableView.isHidden = false
 
        case .loading:
            activityIndicator.startAnimating()
            emptyLabel.isHidden = true
            tableView.isHidden = true
 
        case .loaded:
            activityIndicator.stopAnimating()
            emptyLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
 
        case .error(let message):
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            emptyLabel.isHidden = false
            emptyLabel.text = message
        }
    }
 
    // MARK: - Actions
    @objc private func backTapped() {
        viewModel.didTapBack()
    }
 
    // MARK: - Helpers
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
 
    private func showTradeAlert(for index: Int) {
        guard case .loaded(let offers) = viewModel.state else { return }
        let offer = offers[index]
 
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
 
    private var currentOffers: [P2POfferViewModel] {
        guard case .loaded(let offers) = viewModel.state else { return [] }
        return offers
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentOffers.count
    }
 
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: P2POfferCell.identifier,
            for: indexPath
        ) as! P2POfferCell
 
        cell.configure(with: currentOffers[indexPath.row])
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
 
