// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

public protocol PendingOrderDetailsServiceAPI: AnyObject {
    var pendingOrderDetails: Single<[OrderDetails]> { get }
    var pendingActionOrderDetails: Single<[OrderDetails]> { get }

    func cancel(_ order: OrderDetails) -> Completable
}

final class PendingOrderDetailsService: PendingOrderDetailsServiceAPI {

    var pendingOrderDetails: Single<[OrderDetails]> {
        ordersService.fetchOrders()
            .map { orders in
                orders
                    .filter { !$0.isFinal }
                    .filter { $0.isAwaitingAction || $0.is3DSConfirmedCardOrder }
            }
    }

    var pendingActionOrderDetails: Single<[OrderDetails]> {
        ordersService.fetchOrders()
            .map { orders in
                orders
                    .filter { !$0.isFinal }
                    .filter(\.isAwaitingAction)
            }
    }

    // MARK: - Injected

    private let ordersService: OrdersServiceAPI
    private let cancallationService: OrderCancellationServiceAPI

    // MARK: - Setup

    init(
        ordersService: OrdersServiceAPI = resolve(),
        cancallationService: OrderCancellationServiceAPI = resolve()
    ) {
        self.ordersService = ordersService
        self.cancallationService = cancallationService
    }

    func cancel(_ order: OrderDetails) -> Completable {
        cancallationService.cancel(order: order.identifier)
    }
}
