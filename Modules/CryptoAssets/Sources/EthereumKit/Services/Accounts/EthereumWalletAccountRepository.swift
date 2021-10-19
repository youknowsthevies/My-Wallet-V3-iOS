// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import RxSwift
import ToolKit

public enum WalletAccountRepositoryError: Error {
    case missingWallet
    case failedToFetchAccount(Error)
}

public protocol EthereumWalletAccountRepositoryAPI {

    var defaultAccount: AnyPublisher<EthereumWalletAccount, WalletAccountRepositoryError> { get }
}

final class EthereumWalletAccountRepository: EthereumWalletAccountRepositoryAPI {

    // MARK: - Types

    private struct Key: Hashable {}

    // MARK: - EthereumWalletAccountRepositoryAPI

    var defaultAccount: AnyPublisher<EthereumWalletAccount, WalletAccountRepositoryError> {
        cachedValue.get(key: Key())
    }

    // MARK: - Private Properties

    private let accountBridge: EthereumWalletAccountBridgeAPI
    private let cachedValue: CachedValueNew<
        Key,
        EthereumWalletAccount,
        WalletAccountRepositoryError
    >

    // MARK: - Init

    init(
        accountBridge: EthereumWalletAccountBridgeAPI = resolve()
    ) {
        self.accountBridge = accountBridge

        let cache: AnyCache<Key, EthereumWalletAccount> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [accountBridge] _ in
                accountBridge.wallets
                    .eraseError()
                    .map(\.first)
                    .mapError(WalletAccountRepositoryError.failedToFetchAccount)
                    .onNil(.missingWallet)
                    .map { account in
                        EthereumWalletAccount(
                            index: account.index,
                            publicKey: account.publicKey,
                            label: account.label,
                            archived: account.archived
                        )
                    }
                    .eraseToAnyPublisher()
            }
        )
    }
}
