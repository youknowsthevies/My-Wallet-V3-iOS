// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import ToolKit

/// An AssetLoader that loads some CryptoAssets straight away, and lazy load others.
final class DynamicAssetLoader: AssetLoader {

    // MARK: Properties

    var loadedAssets: [CryptoAsset] {
        storage.value
            .sorted { lhs, rhs in
                lhs.key < rhs.key
            }
            .map(\.value)
    }

    // MARK: Private Properties

    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let erc20AssetFactory: ERC20AssetFactoryAPI
    private let storage: Atomic<[CryptoCurrency: CryptoAsset]> = .init([:])

    // MARK: Init

    init(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        erc20AssetFactory: ERC20AssetFactoryAPI = resolve()
    ) {
        self.enabledCurrenciesService = enabledCurrenciesService
        self.erc20AssetFactory = erc20AssetFactory
    }

    // MARK: Methods

    func initAndPreload() -> AnyPublisher<Void, Never> {
        Deferred { [storage, enabledCurrenciesService] in
            Future<Void, Never> { subscriber in
                let allEnabledCryptoCurrencies = enabledCurrenciesService.allEnabledCryptoCurrencies
                let nonCustodialCoinCodes = NonCustodialCoinCode.allCases.map(\.rawValue)

                // Crypto Assets for coins with Non Custodial support (BTC, BCH, ETH, XLM)
                let nonCustodialAssets = allEnabledCryptoCurrencies
                    .filter(\.isCoin)
                    .filter { nonCustodialCoinCodes.contains($0.code) }
                    .map { cryptoCurrency -> CryptoAsset in
                        DIKit.resolve(tag: cryptoCurrency)
                    }

                // Crypto Assets for coins without Non Custodial support, non-ERC20.
                let custodialAssets = allEnabledCryptoCurrencies
                    .filter(\.isCoin)
                    .filter { !nonCustodialCoinCodes.contains($0.code) }
                    .map { cryptoCurrency -> CryptoAsset in
                        CustodialCryptoAsset(asset: cryptoCurrency)
                    }

                storage.mutate { storage in
                    storage.removeAll()
                    nonCustodialAssets.forEach { asset in
                        storage[asset.asset] = asset
                    }
                    custodialAssets.forEach { asset in
                        storage[asset.asset] = asset
                    }
                }
                subscriber(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Subscript

    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset {
        storage.mutateAndReturn { [erc20AssetFactory] storage in
            guard let cryptoAsset = storage[cryptoCurrency] else {
                let cryptoAsset: CryptoAsset
                switch cryptoCurrency {
                case .coin:
                    cryptoAsset = CustodialCryptoAsset(asset: cryptoCurrency)
                case .erc20(let erc20AssetModel):
                    cryptoAsset = erc20AssetFactory.erc20Asset(erc20AssetModel: erc20AssetModel)
                }
                storage[cryptoCurrency] = cryptoAsset
                return cryptoAsset
            }
            return cryptoAsset
        }
    }
}
