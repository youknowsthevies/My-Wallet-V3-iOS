//
//  OrderConfirmationService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 22/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import ToolKit

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

    // MARK: - Setup
    
    init(analyticsRecorder: AnalyticsEventRecording,
         client: CardOrderConfirmationClientAPI) {
        self.analyticsRecorder = analyticsRecorder
        self.client = client
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
        case .funds:
            partner = .funds
        }
                
        return self.client.confirmOrder(
                with: orderId,
                partner: partner,
                paymentMethodId: paymentMethodId
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
            .map { checkoutData.checkoutData(byAppending: $0) }
    }
}
