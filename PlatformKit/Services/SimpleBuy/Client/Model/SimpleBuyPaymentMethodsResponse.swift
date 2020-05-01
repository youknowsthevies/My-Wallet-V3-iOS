//
//  SimpleBuyPaymentMethodsResponse.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

/// The available payment methods
public struct SimpleBuyPaymentMethodsResponse: Decodable {
    
    /// The method
    struct Method: Decodable {
        
        /// The limits
        struct Limits: Decodable {
            let min: String
            let max: String
        }
        
        /// The type of the method (e.g: `BANK_TRANSFER` / `CARD`)
        let type: String
        
        /// The boundaries of the method (min / max)
        let limits: Limits
        
        /// The supported subtypes of the payment method
        /// e.g cards: ["VISA", "MASTERCARD"]
        let subTypes: [String]
    }
    
    /// The currency for the payment method (e.g: `USD`)
    let currency: String
    
    /// The available methods of payment
    let methods: [Method]
}
