//
//  PriceService.swift
//  PlatformKit
//
//  Created by Paulo on 12/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Foundation
import NetworkKit
import RxSwift
import ToolKit

public protocol PriceServiceAPI {
    func price(for baseCurrency: Currency, in quoteCurrency: Currency) -> Single<PriceQuoteAtTime>
    func price(for baseCurrency: Currency, in quoteCurrency: Currency, at date: Date?) -> Single<PriceQuoteAtTime>
    func priceSeries(within window: PriceWindow, of baseCurrency: CryptoCurrency, in quoteCurrency: FiatCurrency) -> Single<HistoricalPriceSeries>
}

public class PriceService: PriceServiceAPI {

    private let client: PriceClientAPI

    // MARK: - Setup

    public convenience init() {
        self.init(client: resolve())
    }

    public init(client: PriceClientAPI) {
        self.client = client
    }
    
    public func price(for baseCurrency: Currency,
                      in quoteCurrency: Currency) -> Single<PriceQuoteAtTime> {
        self.price(for: baseCurrency, in: quoteCurrency, at: nil)
    }
    
    public func price(for baseCurrency: Currency,
                      in quoteCurrency: Currency,
                      at date: Date? = nil) -> Single<PriceQuoteAtTime> {
        guard baseCurrency.code != quoteCurrency.code else {
            return .just(
                PriceQuoteAtTime(
                    timestamp: date ?? Date(),
                    volume24h: nil,
                    moneyValue: MoneyValue.create(major: "1", currency: quoteCurrency.currency) ?? .zero(currency: quoteCurrency.currency)
                )
            )
        }
        if baseCurrency.isFiatCurrency && quoteCurrency.isFiatCurrency {
            return self.price(for: FiatCurrency(code: baseCurrency.code)!, in: FiatCurrency(code: quoteCurrency.code)!, at: date)
        }

        var timestamp: UInt64?
        if let date = date {
            timestamp = UInt64(date.timeIntervalSince1970)
        }
        return client
            .price(for: baseCurrency.code, in: quoteCurrency.code, at: timestamp)
            .map { try PriceQuoteAtTime(response: $0, currency: quoteCurrency) }
    }
    
    private func price(for baseCurrency: FiatCurrency,
                       in quoteCurrency: FiatCurrency,
                       at date: Date? = nil) -> Single<PriceQuoteAtTime> {
        var timestamp: UInt64?
        if let date = date {
            timestamp = UInt64(date.timeIntervalSince1970)
        }
        let conversionCurrency = CryptoCurrency.bitcoin
        let basePrice = client
            .price(for: conversionCurrency.code, in: baseCurrency.code, at: timestamp)
        let quotePrice = client
            .price(for: conversionCurrency.code, in: quoteCurrency.code, at: timestamp)
        
        return Single
            .zip(basePrice, quotePrice)
            .map { (basePrice, quotePrice) in
                let price = basePrice.price != 0 ? quotePrice.price / basePrice.price : 0
                return PriceQuoteAtTime(
                    timestamp: basePrice.timestamp,
                    volume24h: basePrice.volume24h,
                    moneyValue: MoneyValue.create(major: "\(price)", currency: quoteCurrency.currency)!
                )
            }
    }
    
    public func priceSeries(within window: PriceWindow,
                            of baseCurrency: CryptoCurrency,
                            in quoteCurrency: FiatCurrency) -> Single<HistoricalPriceSeries> {
        let start: TimeInterval = window.timeIntervalSince1970(
            cryptoCurrency: baseCurrency,
            calendar: .current,
            date: Date()
        )
        return client
            .priceSeries(
                of: baseCurrency.code,
                in: quoteCurrency.code,
                start: String(Int(start)),
                scale: String(window.scale)
            )
            .map { HistoricalPriceSeries(currency: baseCurrency, prices: $0) }
    }
}
