//
//  OrderCreationService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 05/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit
import PlatformKit

public protocol SimpleBuyOrderCreationServiceAPI: class {
    func create(using checkoutData: CheckoutData) -> Single<CheckoutData>
}

final class OrderCreationService: SimpleBuyOrderCreationServiceAPI {
    
    // MARK: - Service Error
    
    enum ServiceError: Error {
        case mappingError
    }
    
    // MARK: - Properties
    
    private let analyticsRecorder: AnalyticsEventRecording
    private let client: OrderCreationClientAPI
    private let pendingOrderDetailsService: SimpleBuyPendingOrderDetailsServiceAPI
    private let authenticationService: NabuAuthenticationServiceAPI

    // MARK: - Setup
    
    init(analyticsRecorder: AnalyticsEventRecording,
         client: OrderCreationClientAPI,
         pendingOrderDetailsService: SimpleBuyPendingOrderDetailsServiceAPI,
         authenticationService: NabuAuthenticationServiceAPI) {
        self.analyticsRecorder = analyticsRecorder
        self.client = client
        self.pendingOrderDetailsService = pendingOrderDetailsService
        self.authenticationService = authenticationService
    }
    
    // MARK: - API
    
    public func create(using checkoutData: CheckoutData) -> Single<CheckoutData> {
        let creation = authenticationService.tokenString
            .flatMap(weak: self) { (self, token) -> Single<OrderPayload.Response> in
                let data = OrderPayload.Request(
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
            .map(weak: self) { (self, response) in
                OrderDetails(recorder: self.analyticsRecorder, response: response)
            }
            .map { details -> OrderDetails in
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
