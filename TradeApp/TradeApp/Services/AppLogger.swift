//
//  AppLogger.swift
//  TradeApp
//
//  Created by egor_dmitriev on 19.05.2026.
//

import Foundation
import OSLog

struct AppLogger {
    static let subsystem = Bundle.main.bundleIdentifier ?? ""
    
    static let auth = Logger(subsystem: AppLogger.subsystem, category: "auth")
    static let p2p = Logger(subsystem: AppLogger.subsystem, category: "p2p")
    static let network = Logger(subsystem: AppLogger.subsystem, category: "network")
}

