//
//  AlgorandServices.swift
//  Blockchain
//
//  Created by Paulo on 10/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit

struct AlgorandServices: AlgorandDependencies {
    let activity: ActivityItemEventServiceAPI

    init(simpleBuyOrdersAPI: OrdersServiceAPI = ServiceProvider.default.ordersDetails) {
        activity = ActivityItemEventService(
            transactional: EmptyTransactionalActivityItemEventService(),
            buy: BuyActivityItemEventService(currency: .algorand, service: simpleBuyOrdersAPI),
            swap: EmptySwapActivityItemEventService()
        )
    }
}
