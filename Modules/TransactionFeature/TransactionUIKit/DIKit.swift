// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import TransactionKit

extension DependencyContainer {

    // MARK: - TransactionUIKit Module

    public static var transactionUIKit = module {

        factory { ReceiveCoordinator() }

        // MARK: - Receive

        factory { ReceiveRouter() as ReceiveRouterAPI }

        // MARK: - Hooks

        factory { TransactionAnalyticsHook() }

        // MARK: - Other

        factory { () -> CryptoCurrenciesServiceAPI in
            CryptoCurrenciesService(
                pairsService: DIKit.resolve(),
                priceService: DIKit.resolve()
            )
        }

        factory { TransactionsRouter() as TransactionsRouterAPI }
    }
}
