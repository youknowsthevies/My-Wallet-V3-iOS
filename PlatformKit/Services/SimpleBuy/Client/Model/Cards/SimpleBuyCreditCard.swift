//
//  SimpleBuyCreditCard.swift
//  PlatformKit
//
//  Created by Alex McGregor on 3/30/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct SimpleBuyCreditCard: Decodable {
    
    public struct BillingAddress: Decodable {
        public let lineOne: String
        public let lineTwo: String?
        public let postalCode: String
        public let city: String
        public let state: String?
        public let countryCode: String
    }
    
    let providerType: SimpleBuyCreditCardProviderType
    let activityState: SimpleBuyCreditCardActivityState
    let partner: SimpleBuyCreditCardPartner
    let beneficiaryID: String
    let currencyCode: String
    let billingAddress: BillingAddress?
    let expirationDate: Date?
    let lastFourDigits: String?
}
