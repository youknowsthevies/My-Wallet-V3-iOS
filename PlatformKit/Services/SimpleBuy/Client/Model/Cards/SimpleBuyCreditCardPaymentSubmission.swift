//
//  SimpleBuyCreditCardPaymentSubmission.swift
//  PlatformKit
//
//  Created by Alex McGregor on 3/30/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// A credit card payment submission. Note that clients can include a currency type but it
/// defaults to that of the credit card
public struct SimpleBuyCreditCardPaymentSubmission: Encodable {
    
    /// Amount of the payment in minor value
    public let amount: FiatValue
    
    /// e.g. `SIMPLEBUY`. Defaults to `SIMPLEBUY`
    public let product: String = "SIMPLEBUY"
    
    /// e.g. `SIMPLEBUY` order identifier
    public let productReference: String
    
    /// Token for ApplePay or Google Pay
    public let partnerToken: String
    
    /// CVV Code for the card
    public let verificationCode: String
    
    enum CodingKeys: String, CodingKey {
        case amount
        case product
        case productReference
        case token
        case verification
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount.string, forKey: .amount)
        try container.encode(product, forKey: .product)
        try container.encode(productReference, forKey: .productReference)
        try container.encode(partnerToken, forKey: .token)
        try container.encode(verificationCode, forKey: .verification)
    }
}
