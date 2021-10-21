// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import ToolKit

/// An AssetLoader that loads all possible CryptoAsset straight away.
final class StaticAssetLoader: AssetLoader {

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

    // MARK: Properties

    func initAndPreload() -> AnyPublisher<Void, Never> {
        Deferred { [storage, enabledCurrenciesService, erc20AssetFactory] in
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

                // Crypto Assets for ERC20 tokens.
                let erc20Assets = allEnabledCryptoCurrencies
                    .filter(\.isERC20)
                    .map(\.assetModel)
                    .map { erc20AssetModel in
                        erc20AssetFactory.erc20Asset(erc20AssetModel: erc20AssetModel)
                    }

                storage.mutate { storage in
                    storage.removeAll()
                    nonCustodialAssets.forEach { asset in
                        storage[asset.asset] = asset
                    }
                    custodialAssets.forEach { asset in
                        storage[asset.asset] = asset
                    }
                    erc20Assets.forEach { asset in
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
        guard let asset = storage.value[cryptoCurrency] else {
            fatalError("Unknown crypto currency '\(cryptoCurrency.code)'.")
        }
        return asset
    }
}
