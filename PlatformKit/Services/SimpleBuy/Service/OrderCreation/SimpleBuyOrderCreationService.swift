//
//  SimpleBuyOrderCreationService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 05/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class SimpleBuyOrderCreationService: SimpleBuyOrderCreationServiceAPI {
    
    // MARK: - Properties
    
    private let client: SimpleBuyOrderCreationClientAPI
    private let ordersService: SimpleBuyOrdersServiceAPI
    private let authenticationService: NabuAuthenticationServiceAPI

    // MARK: - Setup
    
    public init(client: SimpleBuyOrderCreationClientAPI,
                ordersService: SimpleBuyOrdersServiceAPI,
                authenticationService: NabuAuthenticationServiceAPI) {
        self.client = client
        self.ordersService = ordersService
        self.authenticationService = authenticationService
    }
    
    // MARK: - API
    
    public func buy(using checkoutData: SimpleBuyCheckoutData) -> Completable {
        let data = SimpleBuyOrderCreationData.Request(
            action: .buy,
            fiatValue: checkoutData.fiatValue,
            for: checkoutData.cryptoCurrency
        )
        return authenticationService.getSessionToken()
            .map { $0.token }
            .flatMap(weak: self) { (self, token) -> Single<SimpleBuyOrderCreationData.Response> in
                self.client.create(order: data, token: token)
            }
            // Fetch the order after creation
            .flatMap(weak: self) { (self, _) in
                self.ordersService.fetchOrders()
            }
            .asCompletable()
    }
}
