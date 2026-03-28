//
//  TradeCell.swift
//  TradeApp
//
//  Created by egor_dmitriev on 27.03.2026.
//

import Foundation
import UIKit

struct TradeMessage {
    let id: UUID
    let text: String
    let tradeType: DecisionTypes
    let details: String?
}

final class TradeCell: UITableViewCell {
    private let stackView = UIStackView()
    private let mainLabel = UILabel()
    private let detailsLabel = UILabel()
    
    var currentMessage: TradeMessage? = nil {
        didSet {
            updateUI()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews()
        makeConstraints()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private methods
private extension TradeCell {
    func updateUI() {
        guard let currentMessage else { return }
        mainLabel.text = currentMessage.text
        
        // colors
        switch currentMessage.tradeType {
        case .buy:
            mainLabel.textColor = .systemGreen
        case .sell:
            mainLabel.textColor = .systemRed
        case .ignore:
            mainLabel.textColor = .systemYellow
        }
        
        if let details = currentMessage.details {
            detailsLabel.isHidden = false
            detailsLabel.text = details
        } else {
            detailsLabel.isHidden = true
        }
    }
    
    func addSubviews() {
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(mainLabel)
        stackView.addArrangedSubview(detailsLabel)
    }
    
    func makeConstraints() {
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
    }
    
     func setupUI() {
         mainLabel.numberOfLines = .zero
         mainLabel.font = .systemFont(ofSize: 16)
         
         detailsLabel.numberOfLines = .zero
         detailsLabel.font = .systemFont(ofSize: 14)
         detailsLabel.textColor = .secondaryLabel
         
         stackView.axis = .vertical
         stackView.spacing = 4
         stackView.translatesAutoresizingMaskIntoConstraints = false
         
         contentView.backgroundColor = .secondarySystemBackground
     }
}

// MARK: Identifier
extension TradeCell {
    static let identifier: String = "TradeCell"
}
