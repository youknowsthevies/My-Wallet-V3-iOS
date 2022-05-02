// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import EthereumKit
import MoneyKit
import PlatformKit

public enum ERC20CryptoAssetServiceError: LocalizedError, Equatable {
    case failedToLoadDefaultAccount
    case failedToLoadReceiveAddress
    case failedToFetchTokens

    public var errorDescription: String? {
        switch self {
        case .failedToLoadDefaultAccount:
            return "Failed to load default account."
        case .failedToLoadReceiveAddress:
            return "Failed to load receive address."
        case .failedToFetchTokens:
            return "Failed to load ERC20 Assets."
        }
    }
}

/// Service to initialise required ERC20 CryptoAsset.
public protocol ERC20CryptoAssetServiceAPI {
    func initialize() -> AnyPublisher<Void, ERC20CryptoAssetServiceError>
}

final class ERC20CryptoAssetService: ERC20CryptoAssetServiceAPI {

    private let accountsRepository: ERC20BalancesRepositoryAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let coincore: CoincoreAPI

    init(
        accountsRepository: ERC20BalancesRepositoryAPI,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI,
        coincore: CoincoreAPI
    ) {
        self.accountsRepository = accountsRepository
        self.coincore = coincore
        self.enabledCurrenciesService = enabledCurrenciesService
    }

    func initialize() -> AnyPublisher<Void, ERC20CryptoAssetServiceError> {
        initializeEthereum
            .zip(initializePolygon)
            .replaceOutput(with: ())
    }

    private var initializeEthereum: AnyPublisher<Void, ERC20CryptoAssetServiceError> {
        Deferred { [coincore] in
            Just(coincore[.ethereum])
        }
        .flatMap(\.defaultAccount)
        .replaceError(with: ERC20CryptoAssetServiceError.failedToLoadDefaultAccount)
        .flatMap { account in
            self.initialize(account: account, network: .ethereum)
        }
        .eraseToAnyPublisher()
    }

    private var initializePolygon: AnyPublisher<Void, ERC20CryptoAssetServiceError> {
        guard enabledCurrenciesService.allEnabledCryptoCurrencies.contains(.polygon) else {
            return .just(())
        }
        return Deferred { [coincore] in
            Just(coincore[.polygon])
        }
        .flatMap(\.defaultAccount)
        .replaceError(with: ERC20CryptoAssetServiceError.failedToLoadDefaultAccount)
        .flatMap { account -> AnyPublisher<Void, ERC20CryptoAssetServiceError> in
            account
                .isFundedPublisher
                .replaceError(with: ERC20CryptoAssetServiceError.failedToLoadDefaultAccount)
                .flatMap { isFunded -> AnyPublisher<Void, ERC20CryptoAssetServiceError> in
                    guard isFunded else {
                        return .just(())
                    }
                    return self.initialize(account: account, network: .polygon)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    private func initialize(
        account: SingleAccount,
        network: EVMNetwork
    ) -> AnyPublisher<Void, ERC20CryptoAssetServiceError> {
        account.receiveAddressPublisher
            .map { receiveAddress -> EthereumAddress? in
                EthereumAddress(address: receiveAddress.address)
            }
            .replaceError(with: ERC20CryptoAssetServiceError.failedToLoadReceiveAddress)
            .onNil(ERC20CryptoAssetServiceError.failedToLoadReceiveAddress)
            .flatMap { [accountsRepository] ethereumAddress in
                accountsRepository.tokens(for: ethereumAddress, network: network)
                    .replaceError(with: ERC20CryptoAssetServiceError.failedToFetchTokens)
            }
            .handleEvents(
                receiveOutput: { [coincore] response -> Void in
                    // For each ERC20 token present in the response.
                    response.keys.forEach { currency in
                        // Gets its CryptoAsset from CoinCore to allow it to be preloaded.
                        _ = coincore[currency]
                    }
                }
            )
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
