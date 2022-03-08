// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public struct GraphData: Hashable {

    public struct Index: Hashable, Decodable {

        public let price: Double
        public let timestamp: Date

        public init(price: Double, timestamp: Date) {
            self.price = price
            self.timestamp = timestamp
        }
    }

    public let series: [Index]

    public let base: CryptoCurrency
    public let quote: FiatCurrency

    public init(series: [GraphData.Index], base: CryptoCurrency, quote: FiatCurrency) {
        self.series = series
        self.base = base
        self.quote = quote
    }
}
