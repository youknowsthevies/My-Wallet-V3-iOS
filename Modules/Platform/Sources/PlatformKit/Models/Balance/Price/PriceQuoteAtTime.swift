// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct PriceQuoteAtTime: Equatable {

    /// The time stamp of the quote
    public let timestamp: Date

    /// The quote value
    public let moneyValue: MoneyValue

    public init(timestamp: Date, moneyValue: MoneyValue) {
        self.timestamp = timestamp
        self.moneyValue = moneyValue
    }
}
