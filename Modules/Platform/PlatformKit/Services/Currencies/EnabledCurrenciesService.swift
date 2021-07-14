// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ToolKit

public protocol EnabledCurrenciesServiceAPI {
    var allEnabledCryptoCurrencies: [CryptoCurrency] { get }
    var allEnabledFiatCurrencies: [FiatCurrency] { get }
    var depositEnabledFiatCurrencies: [FiatCurrency] { get }
    var withdrawEnabledFiatCurrencies: [FiatCurrency] { get }
    /// This returns the supported currencies that a user can link a bank through a partner, eg Yodlee
    var bankTransferEligibleFiatCurrencies: [FiatCurrency] { get }
}

final class EnabledCurrenciesService: EnabledCurrenciesServiceAPI {

    private var nonErc20Currencies: [CryptoCurrency] = [
        .bitcoin,
        .ethereum,
        .bitcoinCash,
        .stellar,
        .other(.algorand),
        .other(.polkadot)
    ].sorted()

    private var erc20Currencies: [CryptoCurrency] {
        repository.erc20Assets
            .currencies
            .compactMap { $0 as? ERC20AssetModel }
            .map { .erc20($0) }
    }

    lazy var allEnabledCryptoCurrencies: [CryptoCurrency] = {
        (nonErc20Currencies + erc20Currencies).sorted()
    }()

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

    private let featureFlagService: InternalFeatureFlagServiceAPI
    private let featureConfigurator: FeatureConfiguring
    private let repository: SupportedAssetsRepositoryAPI

    init(
        featureFlagService: InternalFeatureFlagServiceAPI = resolve(),
        featureConfigurator: FeatureConfiguring = resolve(),
        repository: SupportedAssetsRepositoryAPI = resolve()
    ) {
        self.featureFlagService = featureFlagService
        self.featureConfigurator = featureConfigurator
        self.repository = repository
    }
}
