//
//  SplashScreenViewController.swift
//  TradeApp
//
//  Created by egor_dmitriev on 20.04.2026.
//

import Foundation
import UIKit

final class SplashScreenViewController: UIViewController {
    private let logoImageView = UIImageView(image: UIImage(named: "logo"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        
        setupUI()
        startAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.openMainApp()
        }
    }
}

private extension SplashScreenViewController {
    func setupUI() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func startAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 1
        rotation.repeatCount = .infinity
        logoImageView.layer.add(rotation, forKey: "rotation")
        
        UIView.animate(withDuration: 0.8,
                       delay: 0,
                       options: [.autoreverse, .repeat],
                       animations: {
            self.logoImageView.alpha = 0.3
        })
    }
    
    func openMainApp() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }

        let auth = AuthService.shared

        let nextVC: UIViewController

        if auth.isLoggedIn && auth.isAutoLoginEnabled {
            nextVC = sceneDelegate.createRootViewController()
        } else {
            nextVC = UINavigationController(rootViewController: AuthViewController())
        }

        sceneDelegate.window?.rootViewController = nextVC

        UIView.transition(with: sceneDelegate.window!,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: nil)
    }
}
