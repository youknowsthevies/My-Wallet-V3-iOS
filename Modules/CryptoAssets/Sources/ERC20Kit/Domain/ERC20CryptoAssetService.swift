// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import EthereumKit
import Foundation
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

    private let accountsRepository: ERC20TokenAccountsRepositoryAPI
    private let coincore: CoincoreAPI

    init(
        accountsRepository: ERC20TokenAccountsRepositoryAPI = resolve(),
        coincore: CoincoreAPI = resolve()
    ) {
        self.accountsRepository = accountsRepository
        self.coincore = coincore
    }

    func initialize() -> AnyPublisher<Void, ERC20CryptoAssetServiceError> {
        Deferred { [coincore] in
            Just(coincore[.ethereum])
        }
        .flatMap(\.defaultAccount)
        .replaceError(with: ERC20CryptoAssetServiceError.failedToLoadDefaultAccount)
        .flatMap { account -> AnyPublisher<EthereumAddress, ERC20CryptoAssetServiceError> in
            account.receiveAddress
                .asPublisher()
                .map { receiveAddress -> EthereumAddress? in
                    EthereumAddress(address: receiveAddress.address)
                }
                .replaceError(with: ERC20CryptoAssetServiceError.failedToLoadReceiveAddress)
                .onNil(ERC20CryptoAssetServiceError.failedToLoadReceiveAddress)
        }
        .flatMap { [accountsRepository] ethereumAddress in
            accountsRepository.tokens(for: ethereumAddress)
                .replaceError(with: ERC20CryptoAssetServiceError.failedToFetchTokens)
        }
        .map { [coincore] response -> Void in
            // For each ERC20 token present in the response.
            response.keys.forEach { currency in
                // Gets its CryptoAsset from CoinCore to allow it to be preloaded.
                _ = coincore[currency]
            }
            return ()
        }
        .eraseToAnyPublisher()
    }
}
