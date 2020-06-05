//
//  SimpleBuyOrderCancellationService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 18/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

public protocol SimpleBuyOrderCancellationServiceAPI: class {
    
    /// Cancels an order associated with the given id
    func cancel(order id: String) -> Completable
}

public final class SimpleBuyOrderCancellationService: SimpleBuyOrderCancellationServiceAPI {
    
    // MARK: - Injected
    
    private let client: SimpleBuyOrderCancellationClientAPI
    private let orderDetailsService: SimpleBuyOrdersServiceAPI
    private let authenticationService: NabuAuthenticationServiceAPI

    // MARK: - Setup
    
    public init(client: SimpleBuyOrderCancellationClientAPI,
                orderDetailsService: SimpleBuyOrdersServiceAPI,
                authenticationService: NabuAuthenticationServiceAPI) {
        self.client = client
        self.orderDetailsService = orderDetailsService
        self.authenticationService = authenticationService
    }
    
    // MARK: - Exposed
    
    public func cancel(order id: String) -> Completable {
        authenticationService
            .tokenString
            // Cancel the order
            .flatMapCompletable(weak: self) { (self, token) -> Completable in
                self.client.cancel(order: id, token: token)
            }
            // Fetch the orders anew
            .andThen(orderDetailsService.fetchOrders())
            .asCompletable()
    }
}
