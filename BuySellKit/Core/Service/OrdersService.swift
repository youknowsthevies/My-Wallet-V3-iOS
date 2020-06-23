//
//  OrdersService.swift
//  PlatformKit
//
//  Created by Paulo on 31/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public protocol OrdersServiceAPI: class {

    /// Streams all cached Simple Buy orders from cache, or fetch from
    /// remote if they are not cached
    var orders: Single<[OrderDetails]> { get }
    
    /// Fetches the orders from remote
    func fetchOrders() -> Single<[OrderDetails]>
    
    /// Fetches the order for a given identifier
    func fetchOrder(with identifier: String) -> Single<OrderDetails>
}

final class OrdersService: OrdersServiceAPI {
    
    // MARK: - Service Error
    
    enum ServiceError: Error {
        case mappingError
    }
    
    // MARK: - Exposed
    
    var orders: Single<[OrderDetails]> {
        ordersCachedValue.valueSingle
    }
    
    private let ordersCachedValue = CachedValue<[OrderDetails]>(configuration: .onSubscriptionAndLogin())

    // MARK: - Injected
    
    private let analyticsRecorder: AnalyticsEventRecording
    private let client: OrderDetailsClientAPI
    private let authenticationService: NabuAuthenticationServiceAPI
    private let reactiveWallet: ReactiveWalletAPI
    
    // MARK: - Setup
    
    init(analyticsRecorder: AnalyticsEventRecording,
         client: OrderDetailsClientAPI,
         reactiveWallet: ReactiveWalletAPI,
         authenticationService: NabuAuthenticationServiceAPI) {
        self.analyticsRecorder = analyticsRecorder
        self.client = client
        self.reactiveWallet = reactiveWallet
        self.authenticationService = authenticationService
        
        ordersCachedValue.setFetch {
            reactiveWallet
                .waitUntilInitializedSingle
                .flatMap { _ in
                    authenticationService
                        .tokenString
                        .flatMap { client.orderDetails(token: $0, pendingOnly: false) }
                        .map { rawOrders in
                            rawOrders.compactMap {
                                OrderDetails(recorder: analyticsRecorder, response: $0)
                            }
                        }
                }
        }
    }
    
    func fetchOrders() -> Single<[OrderDetails]> {
        ordersCachedValue.fetchValue
    }
    
    func fetchOrder(with identifier: String) -> Single<OrderDetails> {
        authenticationService
            .tokenString
            .flatMap(weak: self) { (self, token) in
                self.client.orderDetails(with: identifier, token: token)
            }
            .map(weak: self) { (self, response) in
                OrderDetails(recorder: self.analyticsRecorder, response: response)
            }
            .map { details -> OrderDetails in
                guard let details = details else {
                    throw ServiceError.mappingError
                }
                return details
            }
    }
}
