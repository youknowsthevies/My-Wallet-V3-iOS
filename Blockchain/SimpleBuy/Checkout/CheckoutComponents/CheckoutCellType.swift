//
//  CheckoutCellType.swift
//  Blockchain
//
//  Created by AlexM on 1/28/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import ToolKit

enum CheckoutCellType: Hashable {

    enum LineItemType: Hashable {
        case amount(String?)
        case buyingFee(String?)
        case date(String?)
        case estimatedAmount(String?)
        case exchangeRate(String?)
        case orderId(String?)
        case paymentAccountField(SimpleBuyPaymentAccountProperty.Field)
        case paymentMethod(String?)
        case status(String?)
        case totalCost(String?)
    }
    
    case termsAndConditions
    case disclaimer
    case separator
    case lineItem(LineItemType)
    case summary

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

    var content: String? {
        switch self {
        case .amount(let content),
             .buyingFee(let content),
             .date(let content),
             .estimatedAmount(let content),
             .exchangeRate(let content),
             .orderId(let content),
             .paymentMethod(let content),
             .status(let content),
             .totalCost(let content):
            return content
        case .paymentAccountField(let field):
            return field.content
        }
    }

    var title: String {
        typealias LocalizedString = LocalizationConstants.SimpleBuy.Checkout.LineItem
        switch self {
        case .amount:
            return LocalizedString.amount
        case .buyingFee:
            return LocalizedString.buyingFee
        case .date:
            return LocalizedString.date
        case .estimatedAmount:
            return LocalizedString.estimatedAmount
        case .exchangeRate:
            return LocalizedString.exchangeRate
        case .orderId:
            return LocalizedString.orderId
        case .paymentAccountField(let field):
            return field.title
        case .paymentMethod:
            return LocalizedString.paymentMethod
        case .status:
            return LocalizedString.status
        case .totalCost:
            return LocalizedString.totalCost
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

    var descriptionInteractionText: String {
        typealias CopyString = LocalizationConstants.SimpleBuy.Checkout.LineItem.Copyable
        switch self {
        case .paymentAccountField(.iban):
            return "\(CopyString.iban) \(CopyString.copyMessageSuffix)"
        case .paymentAccountField(.bankCode):
            return "\(CopyString.bankCode) \(CopyString.copyMessageSuffix)"
        default:
            return CopyString.defaultCopyMessage
        }
    }

    func presenter() -> LineItemCellPresenting {
        isCopyable ? defaultCopyablePresenter() : defaultPresenter()
    }

    func defaultPresenter() -> DefaultLineItemCellPresenter {
        let interactor = DefaultLineItemCellInteractor(
            title: DefaultLabelContentInteractor(knownValue: title),
            description: DefaultLabelContentInteractor(knownValue: content ?? "")
        )
        return DefaultLineItemCellPresenter(interactor: interactor)
    }

    func defaultCopyablePresenter() -> PasteboardingLineItemCellPresenter {
        PasteboardingLineItemCellPresenter(
            input: .init(
                title: title,
                titleInteractionText: LocalizationConstants.SimpleBuy.Checkout.LineItem.Copyable.copied,
                description: content ?? "",
                descriptionInteractionText: descriptionInteractionText,
                analyticsEvent: analyticsEvent
            ),
            analyticsRecorder: AnalyticsEventRecorder.shared
        )
    }
}
