//
//  PaymentMethod.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import ToolKit

public enum PaymentMethodPayloadType: String, CaseIterable, Encodable {
    case card = "PAYMENT_CARD"
    case bankTransfer = "BANK_ACCOUNT"
    case funds = "FUNDS"
}

/// The available payment methods
public struct PaymentMethod: Equatable {
        
    public enum MethodType: Equatable {
        
        /// Card payment method
        case card(Set<CardType>)

        /// Bank transfer payment method
        case bankTransfer

        /// Funds payment method
        case funds(CurrencyType)
        
        public var isCard: Bool {
            switch self {
            case .card:
                return true
            case .bankTransfer, .funds:
                return false
            }
        }
        
        public var isFunds: Bool {
            switch self {
            case .funds:
                return true
            case .bankTransfer, .card:
                return false
            }
        }
        
        public var isBankTransfer: Bool {
            switch self {
            case .bankTransfer:
                return true
            case .funds, .card:
                return false
            }
        }
        
        public var rawType: PaymentMethodPayloadType {
            switch self {
            case .card:
                return .card
            case .bankTransfer:
                return .bankTransfer
            case .funds:
                return .funds
            }
        }
        
        public var analyticsParameter: AnalyticsEvents.SimpleBuy.PaymentMethod {
            switch self {
            case .card:
                return .card
            case .bankTransfer:
                return .bank
            case .funds:
                return .funds
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
            case .bankTransfer:
                self = .bankTransfer
            case .funds:
                self = .funds(currency)
            }
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.rawType == rhs.rawType
        }
    }

    /// The type of the payment method
    public let type: MethodType
    
    /// The maximum value of payment using that method
    public let max: FiatValue
    
    /// The maximum value of payment using that method
    public let min: FiatValue
    
    init?(currency: String, method: PaymentMethodsResponse.Method, supportedFiatCurrencies: [FiatCurrency]) {
        // Preferrably use the payment method's currency
        let rawCurrency = method.currency ?? currency
        guard let currency = FiatCurrency(code: rawCurrency) else {
            return nil
        }
        
        // Make sure the take exists
        guard let rawType = PaymentMethodPayloadType(rawValue: method.type) else {
            return nil
        }
        
        guard let methodType = MethodType(type: rawType,
                                          subTypes: method.subTypes,
                                          currency: currency,
                                          supportedFiatCurrencies: supportedFiatCurrencies) else {
            return nil
        }
        self.type = methodType
        self.min = FiatValue.create(minor: method.limits.min, currency: currency)!
        self.max = FiatValue.create(minor: method.limits.max, currency: currency)!
    }
    
    public static func == (lhs: PaymentMethod, rhs: PaymentMethod) -> Bool {
        lhs.type == rhs.type
    }
}

extension Array where Element == PaymentMethod {
    init(response: PaymentMethodsResponse, supportedFiatCurrencies: [FiatCurrency]) {
        self.init()
        let methods = response.methods
            .compactMap {
                PaymentMethod(
                    currency: response.currency,
                    method: $0,
                    supportedFiatCurrencies: supportedFiatCurrencies
                )
            }
        append(contentsOf: methods)
    }

    init(methods: [PaymentMethodsResponse.Method], currency: FiatCurrency, supportedFiatCurrencies: [FiatCurrency]) {
        self.init()
        let methods = methods
            .compactMap {
                PaymentMethod(
                    currency: currency.code,
                    method: $0,
                    supportedFiatCurrencies: supportedFiatCurrencies
                )
            }
        append(contentsOf: methods)
    }
    
    public var funds: [PaymentMethod] {
        filter { $0.type.isFunds }
    }
    
    public var fundsCurrencies: [CurrencyType] {
        compactMap { method in
            switch method.type {
            case .funds(let currency):
                return currency
            default:
                return nil
            }
        }
    }
}
