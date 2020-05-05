//
//  SimpleBuyPaymentAccount.swift
//  PlatformKit
//
//  Created by Paulo on 03/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import Localization

/// Protocol describing a SimpleBuyPaymentAccount
public protocol SimpleBuyPaymentAccount {

    /// - Returns: A `Payment Account` if the response matches the requiriments, `nil` otherwise.
    init?(response: SimpleBuyPaymentAccountResponse)
    
    /// A identifier for this SimpleBuyPaymentAccount.
    var identifier: String { get }
    
    /// The state in which this SimpleBuyPaymentAccount is.
    var state: SimpleBuyPaymentAccountProperty.State { get }
    
    /// The currency for this SimpleBuyPaymentAccount.
    var currency: FiatCurrency { get }
    
    /// An array of fields that fully represent this Payment Account for a human consumer.
    var fields: [SimpleBuyPaymentAccountProperty.Field] { get }
}

public enum SimpleBuyPaymentAccountProperty {
    
    /// States in which a `SimpleBuyPaymentAccount` can be.
    public enum State: String, Codable {
        case pending = "PENDING"
        case active = "ACTIVE"
        case blocked = "BLOCKED"
    }

    /// Fields that can be part of a `SimpleBuyPaymentAccount`.
    public enum Field: Hashable {
        case accountNumber(String)
        case sortCode(String)
        case recipientName(String)
        case bankName(String)
        case bankCountry(String)
        case iban(String)
        case bankCode(String)
        
        public var content: String {
            switch self {
            case .accountNumber(let value):
                return value
            case .sortCode(let value):
                return value
            case .recipientName(let value):
                return value
            case .bankName(let value):
                return value
            case .bankCountry(let value):
                return value
            case .iban(let value):
                return value
            case .bankCode(let value):
                return value
            }
        }

        public var title: String {
            typealias LocalizedString = LocalizationConstants.SimpleBuy.Checkout.LineItem
            switch self {
            case .accountNumber:
                return LocalizedString.accountNumber
            case .sortCode:
                return LocalizedString.sortCode
            case .recipientName:
                return LocalizedString.recipient
            case .bankName:
                return LocalizedString.bankName
            case .bankCountry:
                return LocalizedString.bankCountry
            case .iban:
                return LocalizedString.iban
            case .bankCode:
                return LocalizedString.bankCode
            }
        }
    }
}
