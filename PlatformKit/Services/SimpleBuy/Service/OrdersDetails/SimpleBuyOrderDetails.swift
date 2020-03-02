//
//  SimpleBuyOrderDetails.swift
//  PlatformKit
//
//  Created by Paulo on 31/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct SimpleBuyOrderDetails {

    // MARK: - Types
    
    public enum State: String {
        case pendingDeposit = "PENDING_DEPOSIT"
    }
    
    // MARK: - Properties

    public let fiatValue: FiatValue // Sell (fiat for crypto),
    public let cryptoCurrency: CryptoCurrency // Buy (the crypto we would like to buy),
    public let id: String
    
    let state: State
    
    // MARK: - Setup
    
    init?(response: SimpleBuyOrderDetailsResponse) {
        guard let state = State(rawValue: response.state) else {
            return nil
        }
        guard let fiatCurrency = FiatCurrency(code: response.inputCurrency) else {
            return nil
        }
        guard let cryptoCurrency = CryptoCurrency(rawValue: response.outputCurrency) else {
            return nil
        }
        id = response.id
        fiatValue = FiatValue(minor: response.inputQuantity, currency: fiatCurrency)
        self.cryptoCurrency = cryptoCurrency
        self.state = state
    }
}

extension Array where Element == SimpleBuyOrderDetails {
    var pendingDeposit: [SimpleBuyOrderDetails] {
        filter { $0.state == .pendingDeposit }
    }
}
