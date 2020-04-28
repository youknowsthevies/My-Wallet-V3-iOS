//
//  PartnerAuthorizationData.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public struct PartnerAuthorizationData {
    
    public static var exitLink = "https://www.blockchain.com/"
    
    /// Required authorization type
    public enum RequiredAuthorizationType {
        public struct Urls {
            public let paymentLink: URL
            public let exitLink: URL
            
            init(paymentLink: URL) {
                self.paymentLink = paymentLink
                self.exitLink = URL(string: PartnerAuthorizationData.exitLink)!
            }
        }
        
        /// Requires user user authorization by visiting the associated link
        case url(Urls)
        
        /// Authorized to proceed - no auth required
        case none
    }
    
    /// The type of required authorization
    public let requiredAuthorizationType: RequiredAuthorizationType
    
    /// The payment method id that needs to be authorized
    public let paymentMethodId: String
}

extension PartnerAuthorizationData {
    init?(orderPayloadResponse: SimpleBuyOrderPayload.Response) {
        guard let paymentMethodId = orderPayloadResponse.paymentMethodId else {
            return nil
        }
        self.paymentMethodId = paymentMethodId
        
        if let everypay = orderPayloadResponse.attributes?.everypay {
            switch everypay.paymentState {
            case .waitingFor3DS:
                let url = URL(string: everypay.paymentLink)!
                requiredAuthorizationType = .url(.init(paymentLink: url))
            }
        } else {
            requiredAuthorizationType = .none
        }
    }
}
