//
//  P2POfferCell.swift
//  TradeApp
//
//  Created by egor_dmitriev on 09.05.2026.
//

import Foundation
import UIKit
 
final class P2POfferCell: UITableViewCell {
    static let identifier = "P2POfferCell"
 
    // MARK: Callback
    var onInfoTapped: (() -> Void)?
 
    // MARK: UI
    private let sellerNameLabel = UILabel()
    private let rateLabel = UILabel()
    private let reserveLabel = UILabel()
    private let infoButton = UIButton(type: .infoLight)
    private let labelsStack = UIStackView()
 
    // MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
 
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
 
    // MARK: Configure
    func configure(with vm: P2POfferViewModel) {
        sellerNameLabel.text = vm.sellerName
        rateLabel.text = "Rate: \(vm.rateFormatted)"
        reserveLabel.text = "Reserve: \(vm.reserveFormatted)"
    }
 
    // MARK: Setup
    private func setupUI() {
        sellerNameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
 
        rateLabel.font = .systemFont(ofSize: 13)
        rateLabel.textColor = .secondaryLabel
 
        reserveLabel.font = .systemFont(ofSize: 13)
        reserveLabel.textColor = .secondaryLabel
 
        labelsStack.axis = .vertical
        labelsStack.spacing = 2
        labelsStack.translatesAutoresizingMaskIntoConstraints = false
 
        labelsStack.addArrangedSubview(sellerNameLabel)
        labelsStack.addArrangedSubview(rateLabel)
        labelsStack.addArrangedSubview(reserveLabel)
 
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
 
        contentView.addSubview(labelsStack)
        contentView.addSubview(infoButton)
 
        NSLayoutConstraint.activate([
            labelsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            labelsStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            labelsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            labelsStack.trailingAnchor.constraint(lessThanOrEqualTo: infoButton.leadingAnchor, constant: -8),
 
            infoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            infoButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            infoButton.widthAnchor.constraint(equalToConstant: 30),
            infoButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
 
    @objc private func infoTapped() {
        onInfoTapped?()
    }
}
