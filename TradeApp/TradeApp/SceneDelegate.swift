//
//  SceneDelegate.swift
//  TradeApp
//
//  Created by egor_dmitriev on 19.03.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = createSplashController()
        window?.makeKeyAndVisible()
    }
}

extension SceneDelegate {
    func createSplashController() -> UIViewController {
        return SplashScreenViewController()
    }
    
    func createRootViewController() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        // Trade
        let tradeViewController = TradeViewController()
        tradeViewController.title = "Trade"
        
        let tradeNavigationController = UINavigationController(rootViewController: tradeViewController)
        tradeNavigationController.tabBarItem = UITabBarItem(title: "trade", image: UIImage(systemName: "chart.line.uptrend.xyaxis"), tag: 0)
        
        // Currencies
        let currenciesViewController = CurrenciesViewController()
        currenciesViewController.title = "Currencies"
        
        let currenciesNavigationController = UINavigationController(rootViewController: currenciesViewController)
        currenciesNavigationController.tabBarItem = UITabBarItem(title: "currencies", image: UIImage(systemName: "creditcard.arrow.trianglehead.2.clockwise.rotate.90"), tag: 1)
        
        // Chart
        let chartViewController = ChartViewController()
        chartViewController.title = "Chart"
        
        let chartNavigationController = UINavigationController(rootViewController: chartViewController)
        chartNavigationController.tabBarItem = UITabBarItem(title: "chart", image: UIImage(systemName: "chart.bar.xaxis"), tag: 2)
        
        // Settings
        let settingsVC = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 3)

        tabBarController.viewControllers = [
            tradeNavigationController,
            currenciesNavigationController,
            chartNavigationController,
            settingsNav
        ]
        
        return tabBarController
    }
}

extension SceneDelegate {
    func switchToMain() {
        window?.rootViewController = createRootViewController()
    }

    func switchToAuth() {
        window?.rootViewController = UINavigationController(rootViewController: AuthViewController())
    }
}
