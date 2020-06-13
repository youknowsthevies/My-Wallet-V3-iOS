//
//  OrderConfirmationService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 22/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit
import PlatformKit

public protocol SimpleBuyOrderConfirmationServiceAPI: class {
    func confirm(checkoutData: CheckoutData) -> Single<CheckoutData>
}

final class OrderConfirmationService: SimpleBuyOrderConfirmationServiceAPI {
    
    // MARK: - Service Error
    
    enum ServiceError: Error {
        case mappingError
    }
    
    // MARK: - Properties
    
    private let analyticsRecorder: AnalyticsEventRecording
    private let client: CardOrderConfirmationClientAPI
    private let authenticationService: NabuAuthenticationServiceAPI

    // MARK: - Setup
    
    init(analyticsRecorder: AnalyticsEventRecording,
         client: CardOrderConfirmationClientAPI,
         authenticationService: NabuAuthenticationServiceAPI) {
        self.analyticsRecorder = analyticsRecorder
        self.client = client
        self.authenticationService = authenticationService
    }
    
    public func confirm(checkoutData: CheckoutData) -> Single<CheckoutData> {
        
        let orderId: String
        let partner: OrderPayload.ConfirmOrder.Partner
        
        switch checkoutData.detailType {
        case .order(let details):
            orderId = details.identifier
            if details.paymentMethodId == nil {
                partner = .bank
            } else {
                partner = .everyPay(customerUrl: PartnerAuthorizationData.exitLink)
            }
        case .candidate:
            fatalError("Cannot confirm a candidate order - the detail type value must equal `order`")
        }
        
        return authenticationService
            .tokenString
            .flatMap(weak: self) { (self, token) in
                self.client.confirmOrder(
                    with: orderId,
                    partner: partner,
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
    }
}
