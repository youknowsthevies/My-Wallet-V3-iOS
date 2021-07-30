// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ToolKit

public protocol EnabledCurrenciesServiceAPI {
    var allEnabledCurrencies: [CurrencyType] { get }
    var allEnabledCryptoCurrencies: [CryptoCurrency] { get }
    var allEnabledFiatCurrencies: [FiatCurrency] { get }
    /// This returns the supported currencies that a user can link a bank through a partner, eg Yodlee
    var bankTransferEligibleFiatCurrencies: [FiatCurrency] { get }
}

final class EnabledCurrenciesService: EnabledCurrenciesServiceAPI {

    private let nonErc20Currencies: [CryptoCurrency] = [
        .coin(.bitcoin),
        .coin(.ethereum),
        .coin(.bitcoinCash),
        .coin(.stellar),
        .coin(.algorand),
        .coin(.polkadot)
    ].sorted()

    private lazy var erc20Currencies: [CryptoCurrency] = {
        var models: [ERC20AssetModel] = repository.erc20Assets
            .currencies
            .compactMap { $0 as? ERC20AssetModel }

        // Some ERC20 coins are been controlled by Firebase feature flag `custodial_only_token`, so
        // we will iterate between the known set of ERC20 coins `repository` returned and overwrite
        // these coins 'products' field with `.privateKey` if they are enabled. The ones that aren't
        // enabled will be filtered out.
        let enabledCustodial: Result<[String: [String]], FeatureConfigurationError> = featureConfigurator
            .configuration(for: .custodialOnlyTokens)
        switch enabledCustodial {
        case .failure:
            return models
                .filter { !$0.products.isEmpty }
                .map(CryptoCurrency.erc20)
        case .success(let enabledCustodial):
            let legacyERC20Codes = LegacyERC20Code.allCases.map(\.rawValue)
            return models
                .compactMap { model in
                    guard !legacyERC20Codes.contains(model.code) else {
                        // This is one of the currently supported ERC20 currency, do nothing.
                        return model
                    }
                    guard enabledCustodial.keys.contains(model.code) else {
                        // This currency is completely disabled.
                        return nil
                    }
                    return model.with(products: [.privateKey])
                }
                .filter { !$0.products.isEmpty }
                .map(CryptoCurrency.erc20)
        }
    }()

    private lazy var enabledOptionalCustodial: [CryptoCurrency] = {
        let optionalCustodial: [CryptoCurrency] = [
            .coin(.bitClout),
            .coin(.blockstack),
            .coin(.dogecoin),
            .coin(.eos),
            .coin(.ethereumClassic),
            .coin(.litecoin),
            .coin(.mobileCoin),
            .coin(.near),
            .coin(.tezos),
            .coin(.theta)
        ]
        let enabledCustodial: Result<[String: [String]], FeatureConfigurationError> = featureConfigurator
            .configuration(for: .custodialOnlyTokens)
        switch enabledCustodial {
        case .failure:
            return []
        case .success(let enabledCustodial):
            return optionalCustodial.filter { enabledCustodial.keys.contains($0.code) }
        }
    }()

    lazy var allEnabledCryptoCurrencies: [CryptoCurrency] = {
        (nonErc20Currencies + enabledOptionalCustodial + erc20Currencies).sorted()
    }()

    lazy var allEnabledCurrencies: [CurrencyType] = {
        let crypto: [CurrencyType] = allEnabledCryptoCurrencies
            .map { .crypto($0) }
        let fiat: [CurrencyType] = allEnabledFiatCurrencies
            .map { .fiat($0) }
        return crypto + fiat
    }()

    let allEnabledFiatCurrencies: [FiatCurrency] = [.USD, .EUR, .GBP]

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
