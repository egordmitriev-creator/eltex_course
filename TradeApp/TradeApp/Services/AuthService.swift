//
//  AuthService.swift
//  TradeApp
//
//  Created by egor_dmitriev on 02.05.2026.
//

import Foundation
internal import os

final class AuthService {
    static let shared = AuthService()
    
    private let loginKey = "user_login"
    private let passwordKey = "user_password"
    private let autoLoginKey = "auto_login"
    private let isLoggedInKey = "is_logged_in"

    private init() {}

    // MARK: - Registration
    func register(login: String, password: String) {
        guard !login.isEmpty else {
            AppLogger.auth.error("Registration failed — login is empty")
            return
        }
        guard !password.isEmpty else {
            AppLogger.auth.error("Registration failed — password is empty (login: \(login))")
            return
        }

        UserDefaults.standard.set(login, forKey: loginKey)
        UserDefaults.standard.set(password, forKey: passwordKey)
        AppLogger.auth.info("User registered successfully (login: \(login))")
    }

    // MARK: - Login
    func login(login: String, password: String) -> Bool {
        guard !login.isEmpty, !password.isEmpty else {
            AppLogger.auth.warning("Login attempt with empty credentials")
            return false
        }

        AppLogger.auth.debug("Login attempt (login: \(login))")

        let savedLogin    = UserDefaults.standard.string(forKey: loginKey)
        let savedPassword = UserDefaults.standard.string(forKey: passwordKey)

        guard savedLogin != nil else {
            AppLogger.auth.error("Login failed — no registered user found")
            return false
        }

        let success = (login == savedLogin && password == savedPassword)

        if success {
            UserDefaults.standard.set(true, forKey: isLoggedInKey)
            AppLogger.auth.info("Login succeeded (login: \(login))")
        } else {
            AppLogger.auth.warning("Login failed — wrong credentials (login: \(login))")
        }

        return success
    }

    // MARK: - Logout
    func logout() {
        AppLogger.auth.info("User logged out")
        UserDefaults.standard.set(false, forKey: isLoggedInKey)
    }

    // MARK: - State
    var isLoggedIn: Bool {
        UserDefaults.standard.bool(forKey: isLoggedInKey)
    }

    var isAutoLoginEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: autoLoginKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: autoLoginKey)
            AppLogger.auth.debug("Auto-login \(newValue ? "enabled" : "disabled")")
        }
    }
}
