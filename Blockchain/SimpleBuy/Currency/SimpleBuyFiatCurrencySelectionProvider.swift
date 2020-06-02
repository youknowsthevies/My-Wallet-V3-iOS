//
//  SimpleBuyFiatCurrencySelectionProvider.swift
//  Blockchain
//
//  Created by Paulo on 01/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift

final class SimpleBuyFiatCurrencySelectionProvider: FiatCurrencySelectionProvider {
    var currencies: Observable<[FiatCurrency]> {
        supportedCurrencies.valueObservable.map { Array($0) }
    }

    private let supportedCurrencies: SimpleBuySupportedCurrenciesServiceAPI

    init(supportedCurrencies: SimpleBuySupportedCurrenciesServiceAPI) {
        self.supportedCurrencies = supportedCurrencies
    }
}
