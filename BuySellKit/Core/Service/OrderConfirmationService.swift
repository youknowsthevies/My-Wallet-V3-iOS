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

public protocol OrderConfirmationServiceAPI: class {
    func confirm(checkoutData: CheckoutData) -> Single<CheckoutData>
}

final class OrderConfirmationService: OrderConfirmationServiceAPI {
    
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
        let orderId = checkoutData.order.identifier
        let paymentMethodId = checkoutData.order.paymentMethodId
        let partner: OrderPayload.ConfirmOrder.Partner
        switch checkoutData.order.paymentMethod {
        case .bankTransfer:
            partner = .bank
        case .card:
            partner = .everyPay(customerUrl: PartnerAuthorizationData.exitLink)
        }
                
        return authenticationService
            .tokenString
            .flatMap(weak: self) { (self, token) in
                self.client.confirmOrder(
                    with: orderId,
                    partner: partner,
                    paymentMethodId: paymentMethodId,
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
