//
//  SceneDelegate.swift
//  TradeApp
//
//  Created by egor_dmitriev on 19.03.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = createRootViewController()
        
        window?.makeKeyAndVisible()
    }
}

private extension SceneDelegate {
    func createRootViewController() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        let tradeViewController = TradeViewController()
        tradeViewController.title = "Trade"
        
        let tradeNavigationController = UINavigationController(rootViewController: tradeViewController)
        tradeNavigationController.tabBarItem = UITabBarItem(title: "trade", image: UIImage(systemName: "chart.line.uptrend.xyaxis"), tag: 0)
        
        let currenciesViewController = CurrenciesViewController()
        currenciesViewController.title = "Currencies"
        
        let currenciesNavigationController = UINavigationController(rootViewController: currenciesViewController)
        currenciesNavigationController.tabBarItem = UITabBarItem(title: "currencies", image: UIImage(systemName: "creditcard.arrow.trianglehead.2.clockwise.rotate.90"), tag: 1)
        
        tabBarController.viewControllers = [tradeNavigationController, currenciesNavigationController]
        
        return tabBarController
    }
}
