// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCoinDomain
import Foundation
import MoneyKit
import NetworkError

public struct HistoricalPriceRepository: HistoricalPriceRepositoryAPI {

    let client: HistoricalPriceClientAPI

    public init(_ client: HistoricalPriceClientAPI) {
        self.client = client
    }

    public func fetchGraphData(
        base: CryptoCurrency,
        quote: FiatCurrency,
        series: Series,
        relativeTo: Date
    ) -> AnyPublisher<GraphData, NetworkError> {

        client.fetchPriceIndexes(base: base, quote: quote, series: series, relativeTo: relativeTo)
            .flatMap { [client] data in
                client.fetchPriceIndexes(base: base, quote: quote, series: .now, relativeTo: relativeTo)
                    .map { today in data + today }
                    .eraseToAnyPublisher()
            }
            .map { series in
                GraphData(
                    series: series.map { GraphData.Index(price: $0.price, timestamp: $0.timestamp) },
                    base: base,
                    quote: quote
                )
            }
            .eraseToAnyPublisher()
    }
}

extension HistoricalPriceClientAPI {
    fileprivate func fetchPriceIndexes(
        base: CryptoCurrency,
        quote: FiatCurrency,
        series: Series,
        relativeTo: Date
    ) -> AnyPublisher<[PriceIndex], NetworkError> {
        fetchPriceIndexes(
            baseCode: base.code,
            quoteCode: quote.code,
            window: .init(value: series.window.value, component: series.window.component),
            scale: series.scale.value,
            relativeTo: relativeTo
        )
    }
}
