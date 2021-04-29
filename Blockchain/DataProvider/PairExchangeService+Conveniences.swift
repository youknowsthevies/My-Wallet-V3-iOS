// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit

extension PairExchangeService {
    convenience init(cryptoCurrency: CryptoCurrency,
                     fiatCurrencyService: FiatCurrencySettingsServiceAPI = resolve()) {
        self.init(currency: cryptoCurrency, fiatCurrencyService: fiatCurrencyService)
    }
}
