//
//  P2PScreenState.swift
//  TradeApp
//
//  Created by egor_dmitriev on 10.05.2026.
//

import Foundation

enum P2PScreenState {
   case idle
   case loading
   case loaded([P2POfferViewModel])
   case error(String)
}
