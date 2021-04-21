//
//  CryptoCurrency+BitPayCompatibility.swift
//  TransactionKit
//
//  Created by Dimitrios Chatzieleftheriou on 15/04/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

extension CryptoCurrency {
    /// Indicates whether the currency supports bit pay transactions
    var supportsBitPay: Bool {
        self == .bitcoin
    }
}
