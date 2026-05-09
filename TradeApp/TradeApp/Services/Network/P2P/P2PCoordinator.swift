//
//  P2PCoordinator.swift
//  TradeApp
//
//  Created by egor_dmitriev on 09.05.2026.
//

import Foundation
import UIKit
 
protocol P2PCoordinatorProtocol: AnyObject {
    func start() -> UINavigationController
    func showSellerDetail(_ seller: SellerDetailViewModel)
    func dismiss()
}
 
final class P2PCoordinator: P2PCoordinatorProtocol {
    private weak var presentingViewController: UIViewController?
    private var navigationController: UINavigationController?
 
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
 
    func start() -> UINavigationController {
        let viewModel = P2PViewModel()
        viewModel.coordinator = self
 
        let vc = P2PViewController(viewModel: viewModel)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
 
        navigationController = nav
        return nav
    }
 
    func showSellerDetail(_ seller: SellerDetailViewModel) {
        let vc = SellerDetailViewController(viewModel: seller)
        navigationController?.pushViewController(vc, animated: true)
    }
 
    func dismiss() {
        presentingViewController?.dismiss(animated: true)
    }
}
