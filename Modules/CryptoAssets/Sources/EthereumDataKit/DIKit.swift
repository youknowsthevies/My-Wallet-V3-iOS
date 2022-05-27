// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit

extension DependencyContainer {

    // MARK: - EthereumDataKit Module

    public static var ethereumDataKit = module {

        // MARK: Client

        factory {
            EVMActivityClient(
                apiCode: DIKit.resolve(),
                networkAdapter: DIKit.resolve(),
                requestBuilder: DIKit.resolve()
            ) as EVMActivityClientAPI
        }

        factory {
            TransactionClient(
                networkAdapter: DIKit.resolve(),
                requestBuilder: DIKit.resolve()
            ) as TransactionClientAPI
        }

        factory {
            RPCClient(
                networkAdapter: DIKit.resolve(),
                requestBuilder: DIKit.resolve(),
                apiCode: DIKit.resolve()
            ) as LatestBlockClientAPI
        }

        // MARK: Repository

        single {
            EVMActivityRepository(
                client: DIKit.resolve(),
                latestBlockRepository: DIKit.resolve()
            ) as EVMActivityRepositoryAPI
        }

        single {
            PendingTransactionRepository(
                ethereumClient: DIKit.resolve(),
                evmClient: DIKit.resolve()
            ) as PendingTransactionRepositoryAPI
        }

        single {
            HistoricalTransactionsRepository(
                transactionClient: DIKit.resolve(),
                latestBlockRepository: DIKit.resolve()
            ) as HistoricalTransactionsRepositoryAPI
        }

        single {
            LatestBlockRepository(
                client: DIKit.resolve()
            ) as LatestBlockRepositoryAPI
        }
    }
}
