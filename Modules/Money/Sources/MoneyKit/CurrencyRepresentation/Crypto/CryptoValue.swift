// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt

/// A crypto money value.
public struct CryptoValue: CryptoMoney, Hashable {

    public let amount: BigInt

    public let currency: CryptoCurrency

    /// Creates a crypto value.
    ///
    /// - Parameters:
    ///   - amount:   An amount in minor units.
    ///   - currency: A crypto currency.
    public init(amount: BigInt, currency: CryptoCurrency) {
        self.amount = amount
        self.currency = currency
    }
}

extension CryptoValue: MoneyOperating {}
