//
//  EnabledCurrenciesService.swift
//  PlatformKit
//
//  Created by Daniel on 27/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit

public protocol EnabledCurrenciesServiceAPI {
    var allEnabledCryptoCurrencies: [CryptoCurrency] { get }
    var allEnabledFiatCurrencies: [FiatCurrency] { get }
    var depositEnabledFiatCurrencies: [FiatCurrency] { get }
    var withdrawEnabledFiatCurrencies: [FiatCurrency] { get }
    var allEnabledCurrencyTypes: [CurrencyType] { get }
}

final class EnabledCurrenciesService: EnabledCurrenciesServiceAPI {

    let allEnabledCryptoCurrencies: [CryptoCurrency]
    let allEnabledFiatCurrencies: [FiatCurrency] = [.USD, .EUR, .GBP]
    let depositEnabledFiatCurrencies: [FiatCurrency] = [.EUR, .GBP]
    let withdrawEnabledFiatCurrencies: [FiatCurrency] = [.EUR, .GBP]
    
    var allEnabledCurrencyTypes: [CurrencyType] {
        let crypto = allEnabledCryptoCurrencies.map { $0.currency }
        let fiat = allEnabledFiatCurrencies.map { $0.currency }
        return crypto + fiat
    }
    
    private let featureFetcher: FeatureConfiguring
    
    init(featureFetcher: FeatureConfiguring = resolve()) {
        self.featureFetcher = featureFetcher
        var enabledCryptoCurrency = CryptoCurrency.allCases
        if !featureFetcher.configuration(for: .wDGLDenabled).isEnabled {
            enabledCryptoCurrency = CryptoCurrency.allCases.filter { $0 != CryptoCurrency.wDGLD }
        }
        allEnabledCryptoCurrencies = enabledCryptoCurrency
    }
}
