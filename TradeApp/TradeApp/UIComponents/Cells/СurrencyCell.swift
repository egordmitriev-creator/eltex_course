//
//  СurrencyCell.swift
//  TradeApp
//
//  Created by egor_dmitriev on 02.04.2026.
//

import Foundation
import UIKit

final class CurrencyCell: UICollectionViewCell {
    private let currencyLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupSubview()
        setupConstraints()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension CurrencyCell {
    func setupSubview() {
        contentView.addSubview(currencyLabel)
    }
    
    func setupConstraints() {
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currencyLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            currencyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func setupUI() {
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = .secondarySystemBackground
    }
}

extension CurrencyCell {
    static let identifier = "CurrencyCell"
    
    func update(code: String, disabled: Bool) {
        currencyLabel.text = code
        currencyLabel.textColor = disabled ? .gray : .label
        contentView.alpha = disabled ? 0.5 : 1
    }
}
