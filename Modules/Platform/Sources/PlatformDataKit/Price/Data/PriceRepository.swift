// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NetworkError
import PlatformKit
import ToolKit

final class PriceRepository: PriceRepositoryAPI {

    // MARK: - Setup

    private let client: PriceClientAPI
    private let indexMultiCachedValue: CachedValueNew<
        PriceRequest.IndexMulti.Key,
        PriceResponse.IndexMulti.Response,
        NetworkError
    >

    // MARK: - Setup

    init(client: PriceClientAPI = resolve()) {
        self.client = client
        let inMemoryCache = InMemoryCache<PriceRequest.IndexMulti.Key, PriceResponse.IndexMulti.Response>(
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60)
        )
        .eraseToAnyCache()
        indexMultiCachedValue = CachedValueNew(
            cache: inMemoryCache,
            fetch: { key in
                client.price(bases: key.base, quote: key.quote, time: key.time.timestamp)
            }
        )
    }

    func prices(
        of bases: [Currency],
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<[String: PriceQuoteAtTime], NetworkError> {
        let key = PriceRequest.IndexMulti.Key(
            base: bases.map(\.code).sorted(),
            quote: quote.code,
            time: time
        )
        return indexMultiCachedValue
            .get(key: key)
            .map(\.entries)
            .map { entries -> [String: PriceQuoteAtTime] in
                entries.mapValues { item in
                    PriceQuoteAtTime(
                        timestamp: item.timestamp,
                        moneyValue: .create(major: item.price, currency: quote.currency)
                    )
                }
            }
            .eraseToAnyPublisher()
    }

    func priceSeries(
        of base: CryptoCurrency,
        in quote: FiatCurrency,
        within window: PriceWindow
    ) -> AnyPublisher<HistoricalPriceSeries, NetworkError> {
        let start: TimeInterval = window.timeIntervalSince1970(
            cryptoCurrency: base,
            calendar: .current,
            date: Date()
        )
        return client
            .priceSeries(
                of: base.code,
                in: quote.code,
                start: start.string(with: 0),
                scale: String(window.scale)
            )
            .map { response in
                HistoricalPriceSeries(baseCurrency: base, quoteCurrency: quote, prices: response)
            }
            .eraseToAnyPublisher()
    }
}

extension HistoricalPriceSeries {

    init(baseCurrency: CryptoCurrency, quoteCurrency: Currency, prices: [PriceResponse.Item]) {
        self.init(
            currency: baseCurrency,
            prices: prices.map { item in
                PriceQuoteAtTime(response: item, currency: quoteCurrency)
            }
        )
    }
}

extension PriceQuoteAtTime {

    init(response: PriceResponse.Item, currency: Currency) {
        self.init(
            timestamp: response.timestamp,
            moneyValue: .create(major: response.price, currency: currency.currency)
        )
    }
}
