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

public protocol OrderCreationServiceAPI: class {
    func create(using candidateOrderDetails: CandidateOrderDetails) -> Single<CheckoutData>
}

final class OrderCreationService: OrderCreationServiceAPI {
    
    // MARK: - Service Error
    
    enum ServiceError: Error {
        case mappingError
    }
    
    // MARK: - Properties
    
    private let analyticsRecorder: AnalyticsEventRecording
    private let client: OrderCreationClientAPI
    private let pendingOrderDetailsService: PendingOrderDetailsServiceAPI
    private let authenticationService: NabuAuthenticationServiceAPI

    // MARK: - Setup
    
    init(analyticsRecorder: AnalyticsEventRecording,
         client: OrderCreationClientAPI,
         pendingOrderDetailsService: PendingOrderDetailsServiceAPI,
         authenticationService: NabuAuthenticationServiceAPI) {
        self.analyticsRecorder = analyticsRecorder
        self.client = client
        self.pendingOrderDetailsService = pendingOrderDetailsService
        self.authenticationService = authenticationService
    }
    
    // MARK: - API
    
    func create(using candidateOrderDetails: CandidateOrderDetails) -> Single<CheckoutData> {
        let creation = authenticationService.tokenString
            .flatMap(weak: self) { (self, token) -> Single<OrderPayload.Response> in
                let data = OrderPayload.Request(
                    action: .buy,
                    fiatValue: candidateOrderDetails.fiatValue,
                    for: candidateOrderDetails.cryptoCurrency,
                    paymentType: candidateOrderDetails.paymentMethod.method,
                    paymentMethodId: candidateOrderDetails.paymentMethodId
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
            .map { CheckoutData(order: $0) }
        
        return pendingOrderDetailsService
            .cancel()
            .andThen(creation)
    }
}
