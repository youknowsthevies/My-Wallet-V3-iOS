// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import TransactionKit

extension DependencyContainer {

    // MARK: - TransactionUIKit Module

    public static var transactionUIKit = module {

        factory { SendReceiveCoordinator() }

        // MARK: - Receive

        factory { ReceiveRouter() as ReceiveRouterAPI }

        // MARK: - Send

        factory { SendRouter() as SendRouterAPI }

        // MARK: - Hooks

        factory { TransactionAnalyticsHook() }
    }
}
