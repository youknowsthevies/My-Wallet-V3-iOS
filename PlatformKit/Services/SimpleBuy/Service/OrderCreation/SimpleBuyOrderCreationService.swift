//
//  SimpleBuyOrderCreationService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 05/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class SimpleBuyOrderCreationService: SimpleBuyOrderCreationServiceAPI {
    
    // MARK: - Service Error
    
    enum ServiceError: Error {
        case mappingError
    }
    
    // MARK: - Properties
    
    private let client: SimpleBuyOrderCreationClientAPI
    private let pendingOrderDetailsService: SimpleBuyPendingOrderDetailsServiceAPI
    private let authenticationService: NabuAuthenticationServiceAPI

    // MARK: - Setup
    
    public init(client: SimpleBuyOrderCreationClientAPI,
                pendingOrderDetailsService: SimpleBuyPendingOrderDetailsServiceAPI,
                authenticationService: NabuAuthenticationServiceAPI) {
        self.client = client
        self.pendingOrderDetailsService = pendingOrderDetailsService
        self.authenticationService = authenticationService
    }
    
    // MARK: - API
    
    public func create(using checkoutData: SimpleBuyCheckoutData) -> Single<SimpleBuyCheckoutData> {
        let creation = authenticationService.tokenString
            .flatMap(weak: self) { (self, token) -> Single<SimpleBuyOrderPayload.Response> in
                let data = SimpleBuyOrderPayload.Request(
                    action: .buy,
                    fiatValue: checkoutData.fiatValue,
                    for: checkoutData.cryptoCurrency,
                    paymentMethodId: checkoutData.detailType.paymentMethodId
                )
                return self.client
                    .create(
                        order: data,
                        createPendingOrder: true,
                        token: token
                    )
            }
            .map { SimpleBuyOrderDetails(response: $0) }
            .map { details -> SimpleBuyOrderDetails in
                guard let details = details else {
                    throw ServiceError.mappingError
                }
                return details
            }
            .map { checkoutData.checkoutData(byAppending: $0) }
        
        return pendingOrderDetailsService
            .cancel()
            .andThen(creation)
    }
}
