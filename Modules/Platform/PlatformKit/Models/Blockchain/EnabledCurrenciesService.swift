// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

public protocol EnabledCurrenciesServiceAPI {
    var allEnabledCryptoCurrencies: [CryptoCurrency] { get }
    var allEnabledFiatCurrencies: [FiatCurrency] { get }
    var depositEnabledFiatCurrencies: [FiatCurrency] { get }
    var withdrawEnabledFiatCurrencies: [FiatCurrency] { get }
    var allEnabledCurrencyTypes: [CurrencyType] { get }
}

final class EnabledCurrenciesService: EnabledCurrenciesServiceAPI {

    let allEnabledCryptoCurrencies: [CryptoCurrency] = CryptoCurrency.allCases
    let allEnabledFiatCurrencies: [FiatCurrency] = [.USD, .EUR, .GBP]
    
    var depositEnabledFiatCurrencies: [FiatCurrency] {
        featureFlagService.isEnabled(.withdrawAndDepositACH) ? [.USD, .EUR, .GBP] : [.EUR, .GBP]
    }
    
    var withdrawEnabledFiatCurrencies: [FiatCurrency] {
        featureFlagService.isEnabled(.withdrawAndDepositACH) ? [.USD, .EUR, .GBP] : [.EUR, .GBP]
    }
    
    var allEnabledCurrencyTypes: [CurrencyType] {
        let crypto = allEnabledCryptoCurrencies.map { $0.currency }
        let fiat = allEnabledFiatCurrencies.map { $0.currency }
        return crypto + fiat
    }
    
    private let featureFlagService: InternalFeatureFlagServiceAPI
    
    init(featureFlagService: InternalFeatureFlagServiceAPI = resolve()) {
        self.featureFlagService = featureFlagService
    }
}
