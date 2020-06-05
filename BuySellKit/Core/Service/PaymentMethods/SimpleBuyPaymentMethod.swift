//
//  SimpleBuyPaymentMethod.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

/// The available payment methods
public struct SimpleBuyPaymentMethod: Equatable {
    
    public enum MethodType: Equatable {
        
        enum RawValue {
            static let card = "PAYMENT_CARD"
            static let bankTransfer = "BANK_ACCOUNT"
        }
        
        /// Card payment method
        case card(Set<CardType>)
        
        /// Bank transfer payment method
        case bankTransfer
        
        public var isCard: Bool {
            switch self {
            case .card:
                return true
            case .bankTransfer:
                return false
            }
        }
        
        public var rawValue: String {
            switch self {
            case .card:
                return RawValue.card
            case .bankTransfer:
                return RawValue.bankTransfer
            }
        }
        
        public init?(rawValue: String, subTypes: [String]) {
            switch rawValue {
            case RawValue.card:
                let cardTypes = Set(subTypes.compactMap { CardType(rawValue: $0) })
                /// Addition validation - make sure that if `.card` is returned
                /// at least one sub type is included. e.g: "VISA".
                guard !cardTypes.isEmpty else { return nil }
                self = .card(cardTypes)
            case RawValue.bankTransfer:
                self = .bankTransfer
            default:
                return nil
            }
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue == rhs.rawValue
        }
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
        guard let type = MethodType(rawValue: method.type, subTypes: method.subTypes) else {
            return nil
        }
        
        self.type = type
        min = FiatValue(minor: method.limits.min, currency: currency)
        max = FiatValue(minor: method.limits.max, currency: currency)
    }
    
    public static func == (lhs: SimpleBuyPaymentMethod, rhs: SimpleBuyPaymentMethod) -> Bool {
        lhs.type == rhs.type
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
