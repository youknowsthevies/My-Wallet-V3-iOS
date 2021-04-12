//
//  TransactionLimit.swift
//  TransactionKit
//
//  Created by Alex McGregor on 11/10/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct TransactionLimit {
    public let limit: FiatValue
    public let available: FiatValue
    public let used: FiatValue
    
    init(fiatCurrency: FiatCurrency,
         limit: TransactionLimits.Limit) {
        self.limit = FiatValue.create(
            minor: limit.limit,
            currency: fiatCurrency
        ) ?? .zero(currency: fiatCurrency)
        self.available = FiatValue.create(
            minor: limit.available,
            currency: fiatCurrency
        ) ?? .zero(currency: fiatCurrency)
        self.used = FiatValue.create(
            minor: limit.used,
            currency: fiatCurrency
        ) ?? .zero(currency: fiatCurrency)
    }
}

