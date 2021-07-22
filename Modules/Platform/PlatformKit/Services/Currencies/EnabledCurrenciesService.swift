// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ToolKit

public protocol EnabledCurrenciesServiceAPI {
    var allEnabledCryptoCurrencies: [CryptoCurrency] { get }
    var allEnabledFiatCurrencies: [FiatCurrency] { get }
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

    private lazy var enabledOptionalCustodial: [CryptoCurrency] = {
        let optionalCustodial: [CryptoCurrency] = [
            .erc20(.bat),
            .erc20(.comp),
            .erc20(.dai),
            .erc20(.enj),
            .erc20(.link),
            .erc20(.ogn),
            .erc20(.snx),
            .erc20(.sushi),
            .erc20(.tbtc),
            .erc20(.uni),
            .erc20(.usdc),
            .erc20(.wbtc),
            .erc20(.zrx),
            .other(.bitClout),
            .other(.blockstack),
            .other(.dogecoin),
            .other(.eos),
            .other(.ethereumClassic),
            .other(.litecoin),
            .other(.mobileCoin),
            .other(.near),
            .other(.tezos),
            .other(.theta)
        ]
        let enabledCustodial: Result<[String: [String]], FeatureConfigurationError> = featureConfigurator.configuration(for: .custodialOnlyTokens)
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
