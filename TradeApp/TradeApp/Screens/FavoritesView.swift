//
//  FavoritesView.swift
//  TradeApp
//
//  Created by egor_dmitriev on 03.04.2026.
//

import Foundation
import UIKit

protocol FavoritesViewDelegate: AnyObject {
    func didToggleFavorite(isOn: Bool)
}

final class FavoritesView: UIView {
    private let stack = UIStackView()
    private let label = UILabel()
    private let toggle = UISwitch()
    
    weak var delegate: FavoritesViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setutSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

private extension FavoritesView {
    func setupUI() {
        label.text = "Избранное"
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    func setutSubviews() {
        addSubview(stack)
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(toggle)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    @objc func valueChanged() {
        delegate?.didToggleFavorite(isOn: toggle.isOn)
    }
}
