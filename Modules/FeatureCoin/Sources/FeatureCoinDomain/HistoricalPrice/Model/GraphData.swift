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

// MARK: - Preview Helper

extension GraphData {

    public static var preview: GraphData {
        let series = Series(window: Interval(value: 1, component: .weekOfMonth), scale: ._1_hour)
        return GraphData(
            series: stride(
                from: Double.pi,
                to: series.cycles * Double.pi,
                by: Double.pi / Double(180)
            )
            .map { sin($0) + 1 }
            .enumerated()
            .map {
                .init(
                    price: $1 * 10,
                    timestamp: Date(timeIntervalSinceNow: Double($0) * 60 * series.cycles)
                )
            },
            base: .bitcoin,
            quote: .USD
        )
    }
}

extension Series {

    var cycles: Double {
        switch self {
        case .day:
            return 2
        case .week:
            return 3
        case .month:
            return 4
        case .year:
            return 5
        case .all:
            return 6
        default:
            return 1
        }
    }
}
