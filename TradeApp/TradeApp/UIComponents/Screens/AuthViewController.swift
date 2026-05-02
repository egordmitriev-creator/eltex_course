//
//  AuthViewController.swift
//  TradeApp
//
//  Created by egor_dmitriev on 02.05.2026.
//

import Foundation
import UIKit

final class AuthViewController: UIViewController {
    private let logoImageView = UIImageView(image: UIImage(named: "logo"))
    private let loginField = UITextField()
    private let passwordField = UITextField()
    private let actionButton = UIButton()
    private let modeSwitch = UISegmentedControl(items: ["Вход", "Регистрация"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        view.backgroundColor = .systemBackground
        title = "Auth"
        
        setupUI()
    }
}

// MARK: - UI
private extension AuthViewController {
    func setupUI() {
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        loginField.placeholder = "Логин"
        passwordField.placeholder = "Пароль"
        passwordField.isSecureTextEntry = true
        
        [loginField, passwordField].forEach {
            $0.borderStyle = .roundedRect
        }
        
        actionButton.setTitle("Вперед", for: .normal)
        actionButton.backgroundColor = .systemRed
        actionButton.layer.cornerRadius = 8
        
        modeSwitch.selectedSegmentIndex = 0
        
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [
            logoImageView,
            loginField,
            passwordField,
            actionButton,
            modeSwitch
        ])
        
        stack.alignment = .fill
        stack.axis = .vertical
        stack.spacing = 12
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        logoImageView.centerXAnchor.constraint(equalTo: stack.centerXAnchor).isActive = true
        stack.setCustomSpacing(24, after: logoImageView)
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

// MARK: - Logic
private extension AuthViewController {
    func validate(login: String?, password: String?) -> AuthValidationError? {
        guard let login, !login.isEmpty else {
            return .emptyLogin
        }
        
        guard let password, !password.isEmpty else {
            return .emptyPassword
        }
        
        guard login.count >= 4 else {
            return .shortLogin
        }
        
        guard password.count >= 6 else {
            return .shortPassword
        }
        
        let regex = "^[a-zA-Z0-9]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        guard predicate.evaluate(with: login) else {
            return .invalidLoginFormat
        }
        
        return nil
    }
    
    @objc func actionTapped() {
        let error = validate(login: loginField.text,
                             password: passwordField.text)
        
        if let error {
            showError(error.rawValue)
            return
        }
        
        guard let login = loginField.text,
              let password = passwordField.text else { return }
        
        if modeSwitch.selectedSegmentIndex == 1 {
            AuthService.shared.register(login: login, password: password)
            let _ = AuthService.shared.login(login: login, password: password)
            goToApp()
        } else {
            let success = AuthService.shared.login(login: login, password: password)
            
            if success {
                goToApp()
            } else {
                showError("Неверный логин или пароль")
            }
        }
    }
    
    func goToApp() {
        let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        scene?.switchToMain()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Errors
private extension AuthViewController {
    enum AuthValidationError: String {
        case emptyLogin = "Введите логин"
        case emptyPassword = "Введите пароль"
        case shortLogin = "Логин должен быть минимум 4 символа"
        case shortPassword = "Пароль должен быть минимум 6 символов"
        case invalidLoginFormat = "Логин может содержать только буквы и цифры"
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        
        present(alert, animated: true)
    }
}
