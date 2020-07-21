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
    
    func price(for baseCurrency: Currency, in quoteCurrency: Currency) -> Single<PriceQuoteAtTime> {
        .just(priceQuoteAtTime)
    }
    
    func price(for baseCurrency: Currency, in quoteCurrency: Currency, at date: Date?) -> Single<PriceQuoteAtTime> {
        .just(priceQuoteAtTime)
    }
    

    var historicalPriceSeries: HistoricalPriceSeries = HistoricalPriceSeries(currency: .bitcoin, prices: [.empty])
    var priceQuoteAtTime: PriceQuoteAtTime!


    func priceSeries(within window: PriceWindow, of cryptoCurrency: CryptoCurrency, in fiatCurrency: FiatCurrency) -> Single<HistoricalPriceSeries> {
        .just(historicalPriceSeries)
    }
}
