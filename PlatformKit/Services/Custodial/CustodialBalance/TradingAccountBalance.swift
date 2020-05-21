//
//  CustodialBalance.swift
//  PlatformKit
//
//  Created by Paulo on 10/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Holds custodial balance values for a crypto asset
public struct TradingAccountBalance {
    /// Current available amount
    let available: CryptoValue
    /// Amount on Pending Withdraws
    let pending: CryptoValue

    init(currency: CryptoCurrency, response: CustodialBalanceResponse.Balance) {
        self.available = CryptoValue(minor: response.available, cryptoCurreny: currency) ?? .zero(assetType: currency)
        self.pending = CryptoValue(minor: response.pending, cryptoCurreny: currency) ?? .zero(assetType: currency)
    }
}
