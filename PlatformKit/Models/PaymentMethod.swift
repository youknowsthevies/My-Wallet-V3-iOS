//
//  PaymentMethod.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit

public enum PaymentMethodPayloadType: String, CaseIterable, Encodable {
    case card = "PAYMENT_CARD"
    case bankAccount = "BANK_ACCOUNT"
    case bankTransfer = "BANK_TRANSFER"
    case funds = "FUNDS"
}

/// The available payment methods
public struct PaymentMethod: Equatable {
        
    public enum MethodType: Equatable {
        
        /// Card payment method
        case card(Set<CardType>)

        /// Bank account payment method
        case bankAccount

        /// Bank transfer payment method
        case bankTransfer

        /// Funds payment method
        case funds(CurrencyType)
        
        public var isCard: Bool {
            switch self {
            case .card:
                return true
            case .bankAccount, .bankTransfer, .funds:
                return false
            }
        }
        
        public var isFunds: Bool {
            switch self {
            case .funds:
                return true
            case .bankAccount, .bankTransfer, .card:
                return false
            }
        }
        
        public var isBankAccount: Bool {
            switch self {
            case .bankAccount:
                return true
            case .funds, .card, .bankTransfer:
                return false
            }
        }

        public var isBankTransfer: Bool {
            switch self {
            case .bankTransfer:
                return true
            case .funds, .card, .bankAccount:
                return false
            }
        }
        
        public var rawType: PaymentMethodPayloadType {
            switch self {
            case .card:
                return .card
            case .bankAccount:
                return .bankAccount
            case .funds:
                return .funds
            case .bankTransfer:
                return .bankTransfer
            }
        }
        
        public init?(type: PaymentMethodPayloadType,
                     subTypes: [String],
                     currency: FiatCurrency,
                     supportedFiatCurrencies: [FiatCurrency]) {
            switch type {
            case .card:
                let cardTypes = Set(subTypes.compactMap { CardType(rawValue: $0) })
                /// Addition validation - make sure that if `.card` is returned
                /// at least one sub type is included. e.g: "VISA".
                guard !cardTypes.isEmpty else { return nil }
                self = .card(cardTypes)
            case .bankAccount:
                self = .bankAccount
            case .bankTransfer:
                self = .bankTransfer
            case .funds:
                guard supportedFiatCurrencies.contains(currency) else {
                    return nil
                }
                self = .funds(currency.currency)
            }
        }
        
        public init(type: PaymentMethodPayloadType, currency: CurrencyType) {
            switch type {
            case .card:
                self = .card([])
            case .bankAccount:
                self = .bankAccount
            case .bankTransfer:
                self = .bankTransfer
            case .funds:
                self = .funds(currency)
            }
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.rawType == rhs.rawType
        }

        /// Helper method to determine if the passed MethodType is the same as self
        /// - Parameter otherType: A `MethodType` for the comparison
        /// - Returns: `True` if it is the same MethodType as the passed one otherwise false
        public func isSame(as otherType: MethodType) -> Bool {
            switch (self, otherType) {
            case (.card(let lhs), .card(let rhs)):
                return lhs == rhs
            case (.bankAccount, .bankAccount):
                return true
            case (.bankTransfer, .bankTransfer):
                return true
            case (.funds(let currencyLhs), .funds(let currencyRhs)):
                return currencyLhs == currencyRhs
            default:
                return false
            }
        }
    }

    /// The type of the payment method
    public let type: MethodType
    
    /// The maximum value of payment using that method
    public let max: FiatValue
    
    /// The maximum value of payment using that method
    public let min: FiatValue
    
    public static func == (lhs: PaymentMethod, rhs: PaymentMethod) -> Bool {
        lhs.type == rhs.type
    }

    public init(type: MethodType, max: FiatValue, min: FiatValue) {
        self.type = type
        self.max = max
        self.min = min
    }
}
