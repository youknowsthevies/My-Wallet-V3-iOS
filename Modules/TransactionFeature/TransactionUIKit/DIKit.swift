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
    }
}
