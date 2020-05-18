//
//  SimpleBuyOrderConfirmationService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 22/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public final class SimpleBuyOrderConfirmationService: SimpleBuyOrderConfirmationServiceAPI {
    
    // MARK: - Service Error
    
    enum ServiceError: Error {
        case mappingError
    }
    
    // MARK: - Properties
    
    private let analyticsRecorder: AnalyticsEventRecording
    private let client: SimpleBuyCardOrderConfirmationClientAPI
    private let authenticationService: NabuAuthenticationServiceAPI

    // MARK: - Setup
    
    public init(analyticsRecorder: AnalyticsEventRecording,
                client: SimpleBuyCardOrderConfirmationClientAPI,
                authenticationService: NabuAuthenticationServiceAPI) {
        self.analyticsRecorder = analyticsRecorder
        self.client = client
        self.authenticationService = authenticationService
    }
    
    public func confirm(checkoutData: SimpleBuyCheckoutData) -> Single<SimpleBuyCheckoutData> {
        
        let orderId: String
        let partner: SimpleBuyOrderPayload.ConfirmOrder.Partner
        
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
                SimpleBuyOrderDetails(recorder: self.analyticsRecorder, response: response)
            }
            .map { details -> SimpleBuyOrderDetails in
                guard let details = details else {
                    throw ServiceError.mappingError
                }
                return details
            }
            .map { checkoutData.checkoutData(byAppending: $0) }
    }
}
