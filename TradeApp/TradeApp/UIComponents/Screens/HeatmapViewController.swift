//
//  HeatmapViewController.swift
//  TradeApp
//
//  Created by egor_dmitriev on 27.05.2026.
//

import Foundation
import UIKit
import SwiftUI
 
final class HeatmapViewController: UIViewController {
 
   override func viewDidLoad() {
      super.viewDidLoad()
      title = "Heatmap"
      embedHeatmap()
   }
 
   private func embedHeatmap() {
      let hosting = UIHostingController(rootView: HeatmapView())

      addChild(hosting)
      hosting.view.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(hosting.view)
 
      NSLayoutConstraint.activate([
         hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
         hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
         hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
         hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      ])
 
      hosting.didMove(toParent: self)
   }
}
 
