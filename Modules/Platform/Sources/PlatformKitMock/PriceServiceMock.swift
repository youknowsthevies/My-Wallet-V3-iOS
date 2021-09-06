// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit
import PlatformKit

final class PriceServiceMock: PriceServiceAPI {
    var moneyValuePair: MoneyValuePair!
    var historicalPriceSeries: HistoricalPriceSeries!
    var priceQuoteAtTime: PriceQuoteAtTime!

    func moneyValuePair(
        base fiatValue: FiatValue,
        cryptoCurrency: CryptoCurrency,
        usesFiatAsBase: Bool
    ) -> AnyPublisher<MoneyValuePair, NetworkError> {
        .just(moneyValuePair)
    }

    func price(for baseCurrency: Currency, in quoteCurrency: Currency) -> AnyPublisher<PriceQuoteAtTime, NetworkError> {
        .just(priceQuoteAtTime)
    }

    func price(for baseCurrency: Currency, in quoteCurrency: Currency, at date: Date?) -> AnyPublisher<PriceQuoteAtTime, NetworkError> {
        .just(priceQuoteAtTime)
    }

    func priceSeries(
        within window: PriceWindow,
        of baseCurrency: CryptoCurrency,
        in quoteCurrency: FiatCurrency
    ) -> AnyPublisher<HistoricalPriceSeries, NetworkError> {
        .just(historicalPriceSeries)
    }
}
