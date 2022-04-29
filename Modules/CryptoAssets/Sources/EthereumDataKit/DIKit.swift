// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit

extension DependencyContainer {

    // MARK: - EthereumDataKit Module

    public static var ethereumDataKit = module {

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

        single {
            PendingTransactionRepository(
                ethereumClient: DIKit.resolve()
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
