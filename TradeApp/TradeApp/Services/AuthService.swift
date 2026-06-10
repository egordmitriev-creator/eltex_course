//
//  AuthService.swift
//  TradeApp
//
//  Created by egor_dmitriev on 02.05.2026.
//

import Foundation

final class AuthService {
    static let shared = AuthService()
    
    private let loginKey = "user_login"
    private let passwordKey = "user_password"
    private let autoLoginKey = "auto_login"
    private let isLoggedInKey = "is_logged_in"
    
    private init() {}
    
    // MARK: - Registration
    func register(login: String, password: String) {
        UserDefaults.standard.set(login, forKey: loginKey)
        UserDefaults.standard.set(password, forKey: passwordKey)
    }
    
    // MARK: - Login
    func login(login: String, password: String) -> Bool {
        let savedLogin = UserDefaults.standard.string(forKey: loginKey)
        let savedPassword = UserDefaults.standard.string(forKey: passwordKey)
        
        let success = (login == savedLogin && password == savedPassword)
        
        if success {
            UserDefaults.standard.set(true, forKey: isLoggedInKey)
        }
        
        return success
    }
    
    // MARK: - Logout
    func logout() {
        UserDefaults.standard.set(false, forKey: isLoggedInKey)
    }
    
    // MARK: - State
    var isLoggedIn: Bool {
        UserDefaults.standard.bool(forKey: isLoggedInKey)
    }
    
    var isAutoLoginEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: autoLoginKey) }
        set { UserDefaults.standard.set(newValue, forKey: autoLoginKey) }
    }
}
