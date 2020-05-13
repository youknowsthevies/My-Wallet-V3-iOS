//
//  PriceInFiat.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

public struct PriceInFiatValue: Decodable, Equatable {
    private let base: PriceInFiat
    private let fiatCurrency: FiatCurrency

    init(base: PriceInFiat, fiatCurrency: FiatCurrency) {
        self.base = base
        self.fiatCurrency = fiatCurrency
    }

    public static func ==(lhs: PriceInFiatValue, rhs: PriceInFiatValue) -> Bool {
        lhs.base == rhs.base
            && lhs.fiatCurrency == rhs.fiatCurrency
    }

    public var priceInFiat: FiatValue {
        .create(amount: base.price, currency: fiatCurrency)
    }
}
