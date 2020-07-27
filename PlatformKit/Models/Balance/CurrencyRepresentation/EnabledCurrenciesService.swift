//
//  EnabledCurrenciesService.swift
//  PlatformKit
//
//  Created by Daniel on 27/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit

public final class EnabledCurrenciesService {

    public let allEnabledCryptoCurrencies: [CryptoCurrency]
    public var allEnabledFiatCurrencies: [FiatCurrency] = [.EUR, .GBP]
    
    public var allEnabledCurrencyTypes: [CurrencyType] {
        let crypto = allEnabledCryptoCurrencies.map { $0.currency }
        let fiat = allEnabledFiatCurrencies.map { $0.currency }
        return crypto + fiat
    }
    
    public init(featureFetcher: FeatureConfiguring & FeatureFetching) {
        let allCases = CryptoCurrency.allCases
        if featureFetcher.configuration(for: .tetherEnabled).isEnabled {
            allEnabledCryptoCurrencies = allCases
        } else {
            allEnabledCryptoCurrencies = allCases.filter { $0 != .tether }
        }
    }
}
