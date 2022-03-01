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

public struct HistoricalPrice: Hashable {

    public let base: CryptoCurrency
    public let quote: FiatCurrency

    public init(base: CryptoCurrency, quote: FiatCurrency) {
        self.base = base
        self.quote = quote
    }
}

extension HistoricalPrice {

    public struct Series: Hashable {
        public let window: Interval
        public let scale: Interval
    }

    public struct Interval: Hashable {
        public let value: Int
        public let component: Calendar.Component
    }
}

extension HistoricalPrice.Interval {
    public static let _15_minutes = Self(value: 15, component: .minute)
    public static let hour = Self(value: 1, component: .hour)
    public static let _2_hours = Self(value: 2, component: .hour)
    public static let day = Self(value: 1, component: .day)
    public static let weekdays = Self(value: 5, component: .weekday)
    public static let week = Self(value: 1, component: .weekOfMonth)
    public static let month = Self(value: 1, component: .month)
    public static let year = Self(value: 1, component: .year)
    public static let all = Self(value: 20, component: .year)
}

extension HistoricalPrice.Series {
    public static let _15_minutes = Self(window: ._15_minutes, scale: ._15_minutes)
    public static let day = Self(window: .day, scale: ._15_minutes)
    public static let week = Self(window: .week, scale: .hour)
    public static let month = Self(window: .month, scale: ._2_hours)
    public static let year = Self(window: .year, scale: .day)
    public static let all = Self(window: .all, scale: .weekdays)
}
