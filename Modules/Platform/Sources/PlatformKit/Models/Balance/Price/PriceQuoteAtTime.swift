// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

/// A quoted price in fiat, for one currency, at a specific timestamp.
public struct PriceQuoteAtTime: Equatable {

    /// The timestamp of the quote.
    public let timestamp: Date

    /// The value of the quote.
    public let moneyValue: MoneyValue

    /// The total market cap of the currency.
    public let marketCap: Double?

    /// Creates a quoted price.
    ///
    /// - Parameters:
    ///   - response: A timestamp.
    ///   - currency: A value.
    public init(
        timestamp: Date,
        moneyValue: MoneyValue,
        marketCap: Double? = nil
    ) {
        self.timestamp = timestamp
        self.moneyValue = moneyValue
        self.marketCap = marketCap
    }
}
