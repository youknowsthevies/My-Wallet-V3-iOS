// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain

extension DependencyContainer {

    // MARK: - FeatureTransactionUI Module

    public static var featureTransactionUI = module {

        factory { ReceiveCoordinator() }

        // MARK: - Receive

        factory { ReceiveRouter() as ReceiveRouterAPI }

        // MARK: - Hooks

        factory { TransactionAnalyticsHook() }

        // MARK: - Other

        factory { TransactionsRouter() as TransactionsRouterAPI }
        factory { PaymentMethodLinkingRouter(featureFlagsService: DIKit.resolve()) as PaymentMethodLinkingRouterAPI }

        // MARK: Internal

        factory { PaymentMethodLinkingSelector() as PaymentMethodLinkingSelectorAPI }
        factory { BankAccountLinker() as BankAccountLinkerAPI }
        factory { BankWireLinker() as BankWireLinkerAPI }
        factory { CardLinker() as CardLinkerAPI }
    }
}
