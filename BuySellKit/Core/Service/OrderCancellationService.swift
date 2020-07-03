//
//  OrderCancellationService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

public protocol OrderCancellationServiceAPI: class {
    
    /// Cancels an order associated with the given id
    func cancel(order id: String) -> Completable
}

final class OrderCancellationService: OrderCancellationServiceAPI {
    
    // MARK: - Injected
    
    private let client: OrderCancellationClientAPI
    private let orderDetailsService: OrdersServiceAPI

    // MARK: - Setup
    
    init(client: OrderCancellationClientAPI,
         orderDetailsService: OrdersServiceAPI) {
        self.client = client
        self.orderDetailsService = orderDetailsService
    }
    
    // MARK: - Exposed
    
    public func cancel(order id: String) -> Completable {
            // Cancel the order
            self.client.cancel(order: id)
                // Fetch the orders anew
                .andThen(orderDetailsService.fetchOrders())
                .asCompletable()
    }
}
