// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

class MockEnabledCurrenciesService: EnabledCurrenciesServiceAPI {
    var allEnabledCryptoCurrencies: [CryptoCurrency] = []
    var allEnabledFiatCurrencies: [FiatCurrency] = []
    var depositEnabledFiatCurrencies: [FiatCurrency] = []
    var withdrawEnabledFiatCurrencies: [FiatCurrency] = []
    var allEnabledCurrencyTypes: [CurrencyType] = []
    var bankTransferEligibleFiatCurrencies: [FiatCurrency] = []
}
