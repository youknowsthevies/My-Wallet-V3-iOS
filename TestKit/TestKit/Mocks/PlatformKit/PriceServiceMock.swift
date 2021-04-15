//
//  PriceServiceMock.swift
//  BlockchainTests
//
//  Created by Paulo on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

final class PriceServiceMock: PriceServiceAPI {
    var moneyValuePair: MoneyValuePair!
    var historicalPriceSeries: HistoricalPriceSeries!
    var priceQuoteAtTime: PriceQuoteAtTime!

    func moneyValuePair(base fiatValue: FiatValue, cryptoCurrency: CryptoCurrency, usesFiatAsBase: Bool) -> Single<MoneyValuePair> {
        .just(moneyValuePair)
    }

    func price(for baseCurrency: Currency, in quoteCurrency: Currency) -> Single<PriceQuoteAtTime> {
        .just(priceQuoteAtTime)
    }

    func price(for baseCurrency: Currency, in quoteCurrency: Currency, at date: Date?) -> Single<PriceQuoteAtTime> {
        .just(priceQuoteAtTime)
    }

    func priceSeries(within window: PriceWindow, of baseCurrency: CryptoCurrency, in quoteCurrency: FiatCurrency) -> Single<HistoricalPriceSeries> {
        .just(historicalPriceSeries)
    }
}
