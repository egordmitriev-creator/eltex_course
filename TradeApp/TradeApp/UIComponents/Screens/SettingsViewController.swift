//
//  SettingsViewController.swift
//  TradeApp
//
//  Created by egor_dmitriev on 02.05.2026.
//

import Foundation
import UIKit

final class SettingsViewController: UIViewController {
    private let logoutButton = UIButton()
    private let autoLoginSwitch = UISwitch()
    private let autoLoginLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Settings"
        
        setupUI()
    }
}

// MARK: - UI
private extension SettingsViewController {
    func setupUI() {
        logoutButton.setTitle("Выйти", for: .normal)
        logoutButton.backgroundColor = .systemRed
        logoutButton.layer.cornerRadius = 8
        logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        
        autoLoginLabel.text = "Автовход"
        autoLoginLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        autoLoginSwitch.isOn = AuthService.shared.isAutoLoginEnabled
        autoLoginSwitch.addTarget(self, action: #selector(autoLoginChanged), for: .valueChanged)
        
        let autoLoginStack = UIStackView(arrangedSubviews: [
            autoLoginLabel,
            autoLoginSwitch
        ])
        
        autoLoginStack.axis = .horizontal
        autoLoginStack.spacing = 8
        autoLoginStack.alignment = .center
        autoLoginStack.distribution = .equalSpacing
        
        let stack = UIStackView(arrangedSubviews: [
            autoLoginStack,
            logoutButton
        ])
        
        stack.axis = .vertical
        stack.spacing = 24
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

// MARK: - Logic
private extension SettingsViewController {
    @objc func autoLoginChanged() {
        AuthService.shared.isAutoLoginEnabled = autoLoginSwitch.isOn
    }
    
    @objc func logoutTapped() {
        let alert = UIAlertController(
            title: "Выход",
            message: "Вы уверены?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        alert.addAction(UIAlertAction(title: "Да", style: .destructive) { _ in
            
            AuthService.shared.logout()
            
            let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            scene?.switchToAuth()
        })
        
        present(alert, animated: true)
    }
}
