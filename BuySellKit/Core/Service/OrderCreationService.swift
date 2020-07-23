//
//  OrderCreationService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 05/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import ToolKit

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
    
    // MARK: - Setup
    
    init(analyticsRecorder: AnalyticsEventRecording,
         client: OrderCreationClientAPI,
         pendingOrderDetailsService: PendingOrderDetailsServiceAPI) {
        self.analyticsRecorder = analyticsRecorder
        self.client = client
        self.pendingOrderDetailsService = pendingOrderDetailsService
    }
    
    // MARK: - API
    
    func create(using candidateOrderDetails: CandidateOrderDetails) -> Single<CheckoutData> {
        let data = OrderPayload.Request(
            action: .buy,
            fiatValue: candidateOrderDetails.fiatValue,
            for: candidateOrderDetails.cryptoCurrency,
            paymentType: candidateOrderDetails.paymentMethod.method,
            paymentMethodId: candidateOrderDetails.paymentMethodId
        )
        let creation = client
            .create(
                order: data,
                createPendingOrder: true
            )
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
