//
//  SimpleBuyOrdersService.swift
//  PlatformKit
//
//  Created by Paulo on 31/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import ToolKit

public final class SimpleBuyOrdersService: SimpleBuyOrdersServiceAPI {
    
    // MARK: - Service Error
    
    enum ServiceError: Error {
        case mappingError
    }
    
    // MARK: - Exposed
    
    public var orders: Single<[SimpleBuyOrderDetails]> {
        ordersCachedValue.valueSingle
    }
    
    private let ordersCachedValue = CachedValue<[SimpleBuyOrderDetails]>(configuration: .onSubscriptionAndLogin)

    // MARK: - Injected
    
    private let client: SimpleBuyOrderDetailsClientAPI
    private let authenticationService: NabuAuthenticationServiceAPI
    private let reactiveWallet: ReactiveWalletAPI
    
    // MARK: - Setup
    
    public init(client: SimpleBuyOrderDetailsClientAPI,
                reactiveWallet: ReactiveWalletAPI,
                authenticationService: NabuAuthenticationServiceAPI) {
        self.client = client
        self.reactiveWallet = reactiveWallet
        self.authenticationService = authenticationService
        
        ordersCachedValue.setFetch {
            reactiveWallet
                .waitUntilInitializedSingle
                .flatMap { _ in
                    authenticationService
                        .tokenString
                        .flatMap { client.orderDetails(token: $0) }
                        .map { rawOrders in
                            rawOrders.compactMap { SimpleBuyOrderDetails(response: $0) }
                        }
                }
        }
    }
    
    public func fetchOrders() -> Single<[SimpleBuyOrderDetails]> {
        ordersCachedValue.fetchValue
    }
    
    public func fetchOrder(with identifier: String) -> Single<SimpleBuyOrderDetails> {
        authenticationService
            .tokenString
            .flatMap(weak: self) { (self, token) in
                self.client.orderDetails(with: identifier, token: token)
            }
            .map { SimpleBuyOrderDetails(response: $0) }
            .map { details -> SimpleBuyOrderDetails in
                guard let details = details else {
                    throw ServiceError.mappingError
                }
                return details
            }
    }
}
