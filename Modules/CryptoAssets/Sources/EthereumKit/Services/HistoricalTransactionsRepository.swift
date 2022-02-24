// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import ToolKit

enum HistoricalTransactionsRepositoryError: Error {
    case failed(Error)
}

protocol HistoricalTransactionsRepositoryAPI {
    func transaction(
        network: EVMNetwork,
        identifier: String
    ) -> AnyPublisher<EthereumHistoricalTransaction, HistoricalTransactionsRepositoryError>

    func transactions(
        network: EVMNetwork,
        address: String
    ) -> AnyPublisher<[EthereumHistoricalTransaction], HistoricalTransactionsRepositoryError>
}

final class HistoricalTransactionsRepository: HistoricalTransactionsRepositoryAPI {

    private struct Key: Hashable {
        let network: EVMNetwork
        let identifier: String
    }

    private let transactionClient: TransactionClientAPI
    private let latestBlockRepository: LatestBlockRepositoryAPI

    private let transactionsCachedValue: CachedValueNew<
        Key,
        [EthereumHistoricalTransaction],
        HistoricalTransactionsRepositoryError
    >
    private let transactionCachedValue: CachedValueNew<
        Key,
        EthereumHistoricalTransaction,
        HistoricalTransactionsRepositoryError
    >

    init(
        transactionClient: TransactionClientAPI = resolve(),
        latestBlockRepository: LatestBlockRepositoryAPI = resolve()
    ) {
        self.transactionClient = transactionClient
        self.latestBlockRepository = latestBlockRepository

        let transactionsCache: AnyCache<Key, [EthereumHistoricalTransaction]> = InMemoryCache(
            configuration: .default(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 60)
        ).eraseToAnyCache()

        transactionsCachedValue = CachedValueNew(
            cache: transactionsCache,
            fetch: { [transactionClient] key in
                transactionClient
                    .transactions(
                        network: key.network,
                        for: key.identifier
                    )
                    .eraseError()
                    .zip(
                        latestBlockRepository
                            .latestBlock(network: key.network)
                            .eraseError()
                    )
                    .mapError(HistoricalTransactionsRepositoryError.failed)
                    .map { transactions, latestBlock in
                        transactions.map { transaction in
                            EthereumHistoricalTransaction(
                                response: transaction,
                                accountAddress: key.identifier,
                                latestBlock: latestBlock
                            )
                        }
                        // Sort most recent first.
                        .sorted(by: >)
                    }
                    .eraseToAnyPublisher()
            }
        )
        let transactionCache: AnyCache<Key, EthereumHistoricalTransaction> = InMemoryCache(
            configuration: .default(),
            refreshControl: PeriodicCacheRefreshControl(refreshInterval: 10)
        ).eraseToAnyCache()

        transactionCachedValue = CachedValueNew(
            cache: transactionCache,
            fetch: { [transactionClient] key in
                transactionClient
                    .transaction(
                        network: key.network,
                        with: key.identifier
                    )
                    .eraseError()
                    .zip(
                        latestBlockRepository
                            .latestBlock(network: key.network)
                            .eraseError()
                    )
                    .mapError(HistoricalTransactionsRepositoryError.failed)
                    .map { response, latestBlock in
                        EthereumHistoricalTransaction(
                            response: response,
                            accountAddress: key.identifier,
                            latestBlock: latestBlock
                        )
                    }
                    .eraseToAnyPublisher()
            }
        )
    }

    func transaction(
        network: EVMNetwork,
        identifier: String
    ) -> AnyPublisher<EthereumHistoricalTransaction, HistoricalTransactionsRepositoryError> {
        transactionCachedValue.get(
            key: Key(network: network, identifier: identifier)
        )
    }

    func transactions(
        network: EVMNetwork,
        address: String
    ) -> AnyPublisher<[EthereumHistoricalTransaction], HistoricalTransactionsRepositoryError> {
        transactionsCachedValue.get(
            key: Key(network: network, identifier: address))
    }
}
