//
//  SimpleBuyFiatCurrencySelectionProvider.swift
//  Blockchain
//
//  Created by Paulo on 01/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import PlatformUIKit
import BuySellKit

public final class SimpleBuyFiatCurrencySelectionProvider: FiatCurrencySelectionProvider {
    public var currencies: Observable<[FiatCurrency]> {
        supportedCurrencies.valueObservable.map { Array($0) }
    }

    private let supportedCurrencies: SimpleBuySupportedCurrenciesServiceAPI

    public init(supportedCurrencies: SimpleBuySupportedCurrenciesServiceAPI) {
        self.supportedCurrencies = supportedCurrencies
    }
}
