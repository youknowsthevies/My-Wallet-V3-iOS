//
//  DIKit.swift
//  TransactionUIKit
//
//  Created by Paulo on 01/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

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
