//
//  ViewController.swift
//  TradeApp
//
//  Created by egor_dmitriev on 19.03.2026.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var btn_select_click: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func waluteSelection(_ sender: UIAction) {
        self.btn_select_click.setTitle(sender.title, for: .normal)
    }

}

