// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Foundation

/// A fiat money value.
public struct FiatValue: Fiat, Hashable {

    public let amount: BigInt

    public let currency: FiatCurrency

    /// Creates a fiat value.
    ///
    /// - Parameters:
    ///   - amount:   An amount in minor units.
    ///   - currency: A fiat currency.
    public init(amount: BigInt, currency: FiatCurrency) {
        self.amount = amount
        self.currency = currency
    }
}

extension FiatValue: MoneyOperating {}
