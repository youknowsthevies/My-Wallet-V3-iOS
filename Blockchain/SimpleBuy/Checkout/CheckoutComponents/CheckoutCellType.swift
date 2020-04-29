//
//  CheckoutCellType.swift
//  Blockchain
//
//  Created by AlexM on 1/28/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import ToolKit

enum CheckoutCellType: Hashable {
    enum LineItemType: Hashable {
        case orderId
        case status
        case date
        case totalCost
        case estimatedAmount
        case exchangeRate
        case amount
        case buyingFee
        case paymentAccountField(SimpleBuyPaymentAccountProperty.Field)
        case paymentMethod
        
        var content: String? {
            switch self {
            case .date, .totalCost, .estimatedAmount, .buyingFee,
                 .paymentMethod, .orderId, .status, .amount, .exchangeRate:
                return nil
            case .paymentAccountField(let field):
                return field.content
            }
        }
    }
    
    case termsAndConditions
    case disclaimer
    case separator
    case lineItem(LineItemType)
    case summary
}

extension CheckoutCellType {
    var isInteractable: Bool {
        switch self {
        case .lineItem:
            return true
        case .disclaimer, .separator, .summary, .termsAndConditions:
            return false
        }
    }
}

extension CheckoutCellType.LineItemType {
    
    var paymentAccountField: SimpleBuyPaymentAccountProperty.Field? {
        switch self {
        case .paymentAccountField(let field):
            return field
        case .date, .totalCost, .estimatedAmount, .buyingFee,
             .paymentMethod, .orderId, .status, .amount, .exchangeRate:
            return nil
        }
    }
    
    var title: String {
        typealias LocalizedString = LocalizationConstants.SimpleBuy.Checkout.LineItem
        switch self {
        case .paymentAccountField(.accountNumber):
            return LocalizedString.accountNumber
        case .paymentAccountField(.sortCode):
            return LocalizedString.sortCode
        case .paymentAccountField(.recipientName):
            return LocalizedString.recipient
        case .paymentAccountField(.bankName):
            return LocalizedString.bankName
        case .paymentAccountField(.bankCountry):
            return LocalizedString.bankCountry
        case .paymentAccountField(.iban):
            return LocalizedString.iban
        case .paymentAccountField(.bankCode):
            return LocalizedString.bankCode
        case .orderId:
            return LocalizedString.orderId
        case .status:
            return LocalizedString.status
        case .date:
            return LocalizedString.date
        case .totalCost:
            return LocalizedString.totalCost
        case .estimatedAmount:
            return LocalizedString.estimatedAmount
        case .buyingFee:
            return LocalizedString.buyingFee
        case .paymentMethod:
            return LocalizedString.paymentMethod
        case .amount:
            return LocalizedString.amount
        case .exchangeRate:
            return LocalizedString.exchangeRate
        }
    }
    
    var analyticsEvent: AnalyticsEvents.SimpleBuy? {
        switch self {
        case .paymentAccountField(.bankCode):
            return .sbBankDetailsCopied(bankName: content ?? "")
        default:
            return nil
        }
    }
    
    var isCopyable: Bool {
        switch self {
        case .paymentAccountField(.accountNumber),
             .paymentAccountField(.iban),
             .paymentAccountField(.bankCode),
             .paymentAccountField(.sortCode):
            return true
        default:
            return false
        }
    }
}
