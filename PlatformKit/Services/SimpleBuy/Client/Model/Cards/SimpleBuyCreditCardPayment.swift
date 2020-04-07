//
//  SimpleBuyCreditCardPayment.swift
//  PlatformKit
//
//  Created by Alex McGregor on 3/30/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// A credit card payment.
public struct SimpleBuyCreditCardPayment: Encodable {
    
    public enum Status: String, Encodable {
        
        /// Initial state
        case created = "CREATED"
        
        /// `Auth` failed
        case failed = "FAILED"
        
        /// Payment ready to be captured
        case authorized = "AUTHORIZED"
        
        /// Settled payment refunded
        case refunded = "REFUNDED"
        
        /// Payment funded/completed
        case settled = "SETTLED"
        
        /// User didn't complete verification
        case abandoned = "ABANDONED"
        
        /// Payment cancelled (Auth removed)
        case voided = "VOIDED"
        
        /// User charged back
        case chargeBack = "CHARGED_BACK"
    }
    
    /// Amount of the payment in minor value
    public let amount: FiatValue
    
    /// The fiat currency type
    public let curencyCode: String
    
    /// e.g. `SIMPLEBUY` order identifier
    public let paymentStatus: Status
    
    enum CodingKeys: String, CodingKey {
        case amount
        case currency
        case status
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount.string, forKey: .amount)
        try container.encode(curencyCode, forKey: .currency)
        try container.encode(paymentStatus, forKey: .status)
    }
}
