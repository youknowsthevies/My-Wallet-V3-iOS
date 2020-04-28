//
//  SimpleBuyPaymentMethod.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

/// The available payment methods
public struct SimpleBuyPaymentMethod: Equatable {
    
    public enum MethodType: String {
        
        /// Card payment method
        case card = "CARD"
        
        /// Bank transfer payment method
        case bankTransfer = "BANK_TRANSFER"
    }

    /// The type of the payment method
    public let type: MethodType
    
    /// The maximum value of payment using that method
    public let max: FiatValue
    
    /// The maximum value of payment using that method
    public let min: FiatValue
    
    init?(currency: String, method: SimpleBuyPaymentMethodsResponse.Method) {
        guard let currency = FiatCurrency(code: currency) else {
            return nil
        }
        guard let type = MethodType(rawValue: method.type) else {
            return nil
        }
        self.type = type
        min = FiatValue(minor: method.limits.min, currency: currency)
        max = FiatValue(minor: method.limits.max, currency: currency)
    }
    
    public static func == (lhs: SimpleBuyPaymentMethod, rhs: SimpleBuyPaymentMethod) -> Bool {
        return lhs.type == rhs.type
    }
}

extension Array where Element == SimpleBuyPaymentMethod {
    init(response: SimpleBuyPaymentMethodsResponse) {
        self.init()
        let methods = response.methods
            .compactMap {
                SimpleBuyPaymentMethod(
                    currency: response.currency,
                    method: $0
                )
            }
        append(contentsOf: methods)
    }
}
