//
//  PairExchangeService+Conveniences.swift
//  Blockchain
//
//  Created by Daniel Huri on 01/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit

extension PairExchangeService {
    convenience init(cryptoCurrency: CryptoCurrency,
                     fiatCurrencyService: FiatCurrencySettingsServiceAPI = resolve()) {
        self.init(currency: cryptoCurrency, fiatCurrencyService: fiatCurrencyService)
    }
}
