// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ToolKit

public protocol EnabledCurrenciesServiceAPI {
    var allEnabledCryptoCurrencies: [CryptoCurrency] { get }
    var allEnabledFiatCurrencies: [FiatCurrency] { get }
    var depositEnabledFiatCurrencies: [FiatCurrency] { get }
    var withdrawEnabledFiatCurrencies: [FiatCurrency] { get }
    var allEnabledCurrencyTypes: [CurrencyType] { get }

    /// This returns the supported currencies that a user can link a bank through a partner, eg Yodlee
    var bankTransferEligibleFiatCurrencies: [FiatCurrency] { get }
}

final class EnabledCurrenciesService: EnabledCurrenciesServiceAPI {

    let allEnabledCryptoCurrencies: [CryptoCurrency] = [
        .bitcoin,
        .ethereum,
        .bitcoinCash,
        .stellar,
        .algorand,
        .polkadot,
        .erc20(.aave),
        .erc20(.yearnFinance),
        .erc20(.wdgld),
        .erc20(.pax),
        .erc20(.tether)
    ]
    let allEnabledFiatCurrencies: [FiatCurrency] = [.USD, .EUR, .GBP]

    var depositEnabledFiatCurrencies: [FiatCurrency] {
        featureFlagService.isEnabled(.withdrawAndDepositACH) ? [.USD, .EUR, .GBP] : [.EUR, .GBP]
    }

    var withdrawEnabledFiatCurrencies: [FiatCurrency] {
        featureFlagService.isEnabled(.withdrawAndDepositACH) ? [.USD, .EUR, .GBP] : [.EUR, .GBP]
    }

    var bankTransferEligibleFiatCurrencies: [FiatCurrency] {
        [.USD]
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
