// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// The available payment methods
struct PaymentMethodsResponse: Decodable {
    
    struct Method: Decodable {
        
        /// The limits
        struct Limits: Decodable {
            let min: String
            let max: String
        }
        
        let type: String
        
        /// The boundaries of the method (min / max)
        let limits: Limits
        
        /// The supported subtypes of the payment method
        /// e.g for a card payment method: ["VISA", "MASTERCARD"]
        let subTypes: [String]
        
        /// The currency limiter of the method
        let currency: String?

        /// The eligible state of the payment
        let eligible: Bool
    }
    
    /// The currency for the payment method (e.g: `USD`)
    let currency: String
    
    /// The available methods of payment
    let methods: [Method]
}
