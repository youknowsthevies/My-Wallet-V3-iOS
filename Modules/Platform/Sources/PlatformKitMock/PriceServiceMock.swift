// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkError
import PlatformKit

final class PriceServiceMock: PriceServiceAPI {
    var moneyValuePair: MoneyValuePair!
    var historicalPriceSeries: HistoricalPriceSeries!
    var priceQuoteAtTime: PriceQuoteAtTime!

    func moneyValuePair(
        fiatValue: FiatValue,
        cryptoCurrency: CryptoCurrency,
        usesFiatAsBase: Bool
    ) -> AnyPublisher<MoneyValuePair, PriceServiceError> {
        .just(moneyValuePair)
    }

    func price(
        of base: Currency,
        in quote: Currency
    ) -> AnyPublisher<PriceQuoteAtTime, PriceServiceError> {
        .just(priceQuoteAtTime)
    }

    func price(
        of base: Currency,
        in quote: Currency,
        at time: PriceTime
    ) -> AnyPublisher<PriceQuoteAtTime, PriceServiceError> {
        .just(priceQuoteAtTime)
    }

    func priceSeries(
        of baseCurrency: CryptoCurrency,
        in quoteCurrency: FiatCurrency,
        within window: PriceWindow
    ) -> AnyPublisher<HistoricalPriceSeries, PriceServiceError> {
        .just(historicalPriceSeries)
    }
}
