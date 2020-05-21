//
//  SavingsAccount.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct SavingsAccountBalance {
    
    let available: CryptoValue

    init?(currency: CryptoCurrency,
          response: SavingsAccountBalanceResponse.CurrencyBalance) {
        guard let balance = response.balance else { return nil }
        available = CryptoValue(
            minor: balance,
            cryptoCurreny: currency
            ) ?? .zero(assetType: currency)
    }
}
