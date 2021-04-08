//
//  TransactionConfirmation.swift
//  PlatformKit
//
//  Created by Alex McGregor on 10/22/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public enum TransactionConfirmation: TransactionConfirmationModelable {
    
    case exchangePrice(TransactionConfirmation.Model.ExchangePriceOption)
    case feedTotal(TransactionConfirmation.Model.FeedTotal)
    case source(TransactionConfirmation.Model.Source)
    case destination(TransactionConfirmation.Model.Destination)
    case total(TransactionConfirmation.Model.Total)
    case feeSelection(TransactionConfirmation.Model.FeeSelection)
    case networkFee(TransactionConfirmation.Model.NetworkFee)
    case bitpayCountdown(TransactionConfirmation.Model.BitPayCountdown)
    case errorNotice(TransactionConfirmation.Model.ErrorNotice)
    case swapSourceValue(TransactionConfirmation.Model.SwapSourceValue)
    case swapDestinationValue(TransactionConfirmation.Model.SwapDestinationValue)
    case swapExchangeRate(TransactionConfirmation.Model.SwapExchangeRate)
    case memo(TransactionConfirmation.Model.Memo)
    case description(TransactionConfirmation.Model.Description)
    case largeTransactionWarning(TransactionConfirmation.Model.AnyBoolOption<MoneyValue>)

    public var type: TransactionConfirmation.Kind {
        switch self {
        case .description(let value):
            return value.type
        case .exchangePrice(let value):
            return value.type
        case .feeSelection(let value):
            return value.type
        case .source(let value):
            return value.type
        case .destination(let value):
            return value.type
        case .total(let value):
            return value.type
        case .bitpayCountdown(let value):
            return value.type
        case .errorNotice(let value):
            return value.type
        case .feedTotal(let value):
            return value.type
        case .swapSourceValue(let value):
            return value.type
        case .swapDestinationValue(let value):
            return value.type
        case .swapExchangeRate(let value):
            return value.type
        case .networkFee(let value):
            return value.type
        case .memo(let value):
            return value.type
        case .largeTransactionWarning(let value):
            return value.type
        }
    }

    public var formatted: (title: String, subtitle: String)? {
        switch self {
        case .description(let value):
            return value.formatted
        case .exchangePrice(let value):
            return value.formatted
        case .feeSelection(let value):
            return value.formatted
        case .source(let value):
            return value.formatted
        case .destination(let value):
            return value.formatted
        case .total(let value):
            return value.formatted
        case .bitpayCountdown(let value):
            return value.formatted
        case .errorNotice(let value):
            return value.formatted
        case .feedTotal(let value):
            return value.formatted
        case .swapSourceValue(let value):
            return value.formatted
        case .swapDestinationValue(let value):
            return value.formatted
        case .swapExchangeRate(let value):
            return value.formatted
        case .networkFee(let value):
            return value.formatted
        case .memo(let value):
            return value.formatted
        case .largeTransactionWarning(let value):
            return value.formatted
        }
    }

    /// Is equal ignoring associated value.
    public func bareCompare(to rhs: Self) -> Bool {
        switch (self, rhs) {
        case (.exchangePrice, .exchangePrice),
             (.feeSelection, .feeSelection),
             (.source, .source),
             (.destination, .destination),
             (.total, .total),
             (.bitpayCountdown, .bitpayCountdown),
             (.errorNotice, .errorNotice),
             (.feedTotal, .feedTotal),
             (.swapSourceValue, .swapSourceValue),
             (.swapDestinationValue, .swapDestinationValue),
             (.swapExchangeRate, .swapExchangeRate),
             (.networkFee, .networkFee),
             (.memo, .memo),
             (.description, .description),
             (.largeTransactionWarning, .largeTransactionWarning):
            return true
        default:
            return false
        }
    }
}
