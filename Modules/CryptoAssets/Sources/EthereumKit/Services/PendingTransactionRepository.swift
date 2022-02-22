// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import ToolKit

public enum PendingTransactionRepositoryError: Error {
    case failed(Error)
}

public protocol PendingTransactionRepositoryAPI {
    func isWaitingOnTransaction(
        network: EVMNetwork,
        address: String
    ) -> AnyPublisher<Bool, PendingTransactionRepositoryError>
}

final class PendingTransactionRepository: PendingTransactionRepositoryAPI {

    private struct Key: Hashable {
        let network: EVMNetwork
        let address: String
    }

    private let client: TransactionClientAPI

    private let cachedValue: CachedValueNew<
        Key,
        Bool,
        PendingTransactionRepositoryError
    >

    init(
        client: TransactionClientAPI = resolve()
    ) {
        self.client = client

        let cache: AnyCache<Key, Bool> = InMemoryCache(
            configuration: .onLoginLogoutTransaction(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 5)
        ).eraseToAnyCache()

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [client] key in
                client
                    .transactions(
                        network: key.network,
                        for: key.address
                    )
                    .mapError(PendingTransactionRepositoryError.failed)
                    .map { transactions in
                        transactions.contains(
                            where: { tx in tx.state == .pending }
                        )
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    func isWaitingOnTransaction(
        network: EVMNetwork,
        address: String
    ) -> AnyPublisher<Bool, PendingTransactionRepositoryError> {
        cachedValue.get(
            key: Key(network: network, address: address)
        )
    }
}
