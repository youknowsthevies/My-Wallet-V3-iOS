// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import EthereumKit
import NetworkError
import ToolKit

final class PendingTransactionRepository: PendingTransactionRepositoryAPI {

    private struct Key: Hashable {
        let network: EVMNetwork
        let address: String
    }

    private let ethereumClient: TransactionClientAPI

    private let cachedValue: CachedValueNew<
        Key,
        Bool,
        NetworkError
    >

    init(
        ethereumClient: TransactionClientAPI
    ) {
        self.ethereumClient = ethereumClient

        let cache: AnyCache<Key, Bool> = InMemoryCache(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 5)
        ).eraseToAnyCache()

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [ethereumClient] key in
                switch key.network {
                case .ethereum:
                    return ethereumClient
                        .transactions(for: key.address)
                        .map { transactions in
                            transactions.contains(
                                where: { tx in tx.state == .pending }
                            )
                        }
                        .eraseToAnyPublisher()
                case .polygon:
                    // No support yet
                    // Allow transactions for now.
                    return .just(false)
                }
            }
        )
    }

    func isWaitingOnTransaction(
        network: EVMNetwork,
        address: String
    ) -> AnyPublisher<Bool, NetworkError> {
        cachedValue.get(
            key: Key(network: network, address: address)
        )
    }
}
