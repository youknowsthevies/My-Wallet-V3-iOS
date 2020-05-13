//
//  PriceService.swift
//  PlatformKit
//
//  Created by Paulo on 12/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import NetworkKit

public protocol PriceServiceAPI {

    func price(for cryptoCurrency: CryptoCurrency, in fiatCurrency: FiatCurrency) -> Single<PriceInFiatValue>
    func price(for cryptoCurrency: CryptoCurrency, in fiatCurrency: FiatCurrency, at date: Date) -> Single<PriceInFiatValue>
    func priceSeries(within window: PriceWindow,
                     of cryptoCurrency: CryptoCurrency,
                     in fiatCurrency: FiatCurrency) -> Single<HistoricalPriceSeries>
}

public class PriceService: PriceServiceAPI {

    private let client: PriceClientAPI

    // MARK: - Setup

    public convenience init() {
        self.init(client: PriceClient())
    }

    public init(client: PriceClientAPI) {
        self.client = client
    }

    public func price(for cryptoCurrency: CryptoCurrency, in fiatCurrency: FiatCurrency) -> Single<PriceInFiatValue> {
        client
            .price(for: cryptoCurrency, in: fiatCurrency, at: nil)
            .map { $0.toPriceInFiatValue(fiatCurrency: fiatCurrency) }
    }

    public func price(for cryptoCurrency: CryptoCurrency, in fiatCurrency: FiatCurrency, at date: Date) -> Single<PriceInFiatValue> {
        client
            .price(for: cryptoCurrency, in: fiatCurrency, at: UInt64(date.timeIntervalSince1970))
            .map { $0.toPriceInFiatValue(fiatCurrency: fiatCurrency) }
    }

    public func priceSeries(within window: PriceWindow,
                            of cryptoCurrency: CryptoCurrency,
                            in fiatCurrency: FiatCurrency) -> Single<HistoricalPriceSeries> {
        let start: TimeInterval = window.timeIntervalSince1970(
            cryptoCurrency: cryptoCurrency,
            calendar: .current,
            date: Date()
        )
        return client
            .priceSeries(
                of: cryptoCurrency,
                in: fiatCurrency,
                start: String(Int(start)),
                scale: String(window.scale)
            )
            .map { HistoricalPriceSeries(currency: cryptoCurrency, prices: $0) }
    }
}
