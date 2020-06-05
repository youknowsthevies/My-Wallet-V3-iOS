//
//  PriceServiceMock.swift
//  BlockchainTests
//
//  Created by Paulo on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

final class PriceServiceMock: PriceServiceAPI {

    var historicalPriceSeries: HistoricalPriceSeries = HistoricalPriceSeries(currency: .bitcoin, prices: [.empty])
    var priceInFiatValue: PriceInFiatValue = PriceInFiat.empty.toPriceInFiatValue(fiatCurrency: .USD)

    func price(for cryptoCurrency: CryptoCurrency, in fiatCurrency: FiatCurrency) -> Single<PriceInFiatValue> {
        .just(priceInFiatValue)
    }

    func price(for cryptoCurrency: CryptoCurrency, in fiatCurrency: FiatCurrency, at date: Date) -> Single<PriceInFiatValue> {
        .just(priceInFiatValue)
    }

    func priceSeries(within window: PriceWindow, of cryptoCurrency: CryptoCurrency, in fiatCurrency: FiatCurrency) -> Single<HistoricalPriceSeries> {
        .just(historicalPriceSeries)
    }
}
