//
//  СurrencyCell.swift
//  TradeApp
//
//  Created by egor_dmitriev on 02.04.2026.
//

import Foundation
import UIKit

// MARK: - Delegate
protocol CurrencyCellDelegate: AnyObject {
    func didTapFavorite(code: String)
}

final class CurrencyCell: UICollectionViewCell {
    private let currencyLabel: UILabel = UILabel()
    private let favoriteButton: UIButton = UIButton()
    
    weak var delegate: CurrencyCellDelegate?
    private var code: String = ""
    
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
        contentView.addSubview(favoriteButton)
    }
    
    func setupConstraints() {
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            currencyLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            currencyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            favoriteButton.widthAnchor.constraint(equalToConstant: 16),
            favoriteButton.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    func setupUI() {
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = .secondarySystemBackground
        
        favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        favoriteButton.tintColor = .systemGray
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
    }
    
    @objc func favoriteTapped() {
        delegate?.didTapFavorite(code: code)
    }
}

extension CurrencyCell {
    static let identifier = "CurrencyCell"
    
    func update(code: String, disabled: Bool, isFavorite: Bool) {
        self.code = code
        currencyLabel.text = code
        
        let imageName = isFavorite ? "star.fill" : "star"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        favoriteButton.tintColor = isFavorite ? .systemYellow: .systemGray
        
        currencyLabel.textColor = disabled ? .gray : .label
        contentView.alpha = disabled ? 0.5 : 1
    }
}

//MARK: Animation
extension CurrencyCell {
    func animateSelection() {
        // 1. scale animation
        UIView.animate(withDuration: 0.12,
                       animations: {
            self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }, completion: { _ in
            UIView.animate(withDuration: 0.12) {
                self.transform = .identity
            }
        })
        
        // 2. background color animation
        let originalColor = contentView.backgroundColor
        
        UIView.animate(withDuration: 0.25,
                       animations: {
            self.contentView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
        }, completion: { _ in
            UIView.animate(withDuration: 0.25) {
                self.contentView.backgroundColor = originalColor
            }
        })
    }
}
