// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct HistoricalPriceSeries {

    public let currency: CryptoCurrency
    /// The difference in percentage between the latest price to the first price
    public let delta: Double
    public let deltaPercentage: Double
    public let prices: [PriceQuoteAtTime]
    public let fiatChange: Decimal

    public init(currency: CryptoCurrency, prices: [PriceQuoteAtTime]) {
        if let first = prices.first, let latest = prices.last {
            let fiatChange = latest.moneyValue.displayMajorValue - first.moneyValue.displayMajorValue
            let delta = fiatChange.doubleValue / first.moneyValue.displayMajorValue.doubleValue
            self.init(currency: currency, delta: delta, deltaPercentage: delta * 100, prices: prices, fiatChange: fiatChange)
        } else {
            self.init(currency: currency, delta: 0, deltaPercentage: 0, prices: [], fiatChange: 0)
        }
    }

    private init(
        currency: CryptoCurrency,
        delta: Double,
        deltaPercentage: Double,
        prices: [PriceQuoteAtTime],
        fiatChange: Decimal
    ) {
        self.currency = currency
        self.delta = delta
        self.deltaPercentage = deltaPercentage
        self.prices = prices
        self.fiatChange = fiatChange
    }
}
