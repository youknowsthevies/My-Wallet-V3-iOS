//
//  BillingAddress.swift
//  PlatformKit
//
//  Created by Daniel Huri on 03/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public struct BillingAddress {
    public let country: Country
    public let fullName: String
    public let addressLine1: String
    public let addressLine2: String
    public let state: String
    public let postCode: String
    
    public init?(country: Country,
                 fullName: String?,
                 addressLine1: String?,
                 addressLine2: String?,
                 state: String?,
                 postCode: String?) {
        guard let fullName = fullName,
              let addressLine1 = addressLine1,
              let postCode = postCode else {
            return nil
        }
                
        /// Countries that have state subdomain require `state` to be initialized
        if country.hasStatesSubdomain {
            guard let state = state else { return nil }
            self.state = state
        } else {
            self.state = ""
        }
        
        self.country = country
        self.fullName = fullName
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2 ?? ""
        self.postCode = postCode
    }
}

private extension Country {
    var hasStatesSubdomain: Bool {
        switch self {
        case .US:
            return true
        default:
            return false
        }
    }
}
