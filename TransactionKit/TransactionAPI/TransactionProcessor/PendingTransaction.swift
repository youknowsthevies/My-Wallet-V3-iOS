//
//  PendingTransaction.swift
//  PlatformKit
//
//  Created by Alex McGregor on 10/15/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct PendingTransaction: Equatable {

    public enum EngineStateKey: String {
        case quoteSubscription
        case userTiers
        case xlmMemo
    }

    public var amount: MoneyValue
    // The source account actionable balance minus the fees for the current fee level.
    public var available: MoneyValue
    public var fees: MoneyValue
    public var selectedFiatCurrency: FiatCurrency
    public var feeLevel: FeeLevel
    public var customFeeAmount: MoneyValue?
    public var confirmations: [TransactionConfirmation] = []
    public var minimumLimit: MoneyValue?
    public var maximumLimit: MoneyValue?
    public var minimumApiLimit: MoneyValue?
    public var validationState: TransactionValidationState = .uninitialized
    public var engineState: [EngineStateKey: Any] = [:]

    public init(amount: MoneyValue,
                available: MoneyValue,
                fees: MoneyValue,
                feeLevel: FeeLevel,
                selectedFiatCurrency: FiatCurrency,
                minimumLimit: MoneyValue? = nil,
                maximumLimit: MoneyValue? = nil) {
        self.amount = amount
        self.available = available
        self.fees = fees
        self.feeLevel = feeLevel
        self.selectedFiatCurrency = selectedFiatCurrency
        self.minimumLimit = minimumLimit
        self.maximumLimit = maximumLimit
    }
    
    public func update(validationState: TransactionValidationState) -> PendingTransaction {
        var copy = self
        copy.validationState = validationState
        return copy
    }
    
    public func update(amount: MoneyValue, available: MoneyValue) -> PendingTransaction {
        var copy = self
        copy.amount = amount
        copy.available = available
        return copy
    }
    
    public func update(amount: MoneyValue, available: MoneyValue, fees: MoneyValue) -> PendingTransaction {
        var copy = self
        copy.amount = amount
        copy.available = available
        copy.fees = fees
        return copy
    }

    public func insert(confirmation: TransactionConfirmation, prepend: Bool = false) -> PendingTransaction {
        var copy = self
        if let idx = copy.confirmations.firstIndex(where: { $0.bareCompare(to: confirmation) }) {
            copy.confirmations.replaceSubrange(idx...idx, with: [confirmation])
        } else {
            prepend ? copy.confirmations.insert(confirmation, at: 0) : copy.confirmations.append(confirmation)
        }
        return copy
    }
    
    public func insert(confirmations: [TransactionConfirmation]) -> PendingTransaction {
        var copy = self
        copy.confirmations.append(contentsOf: confirmations)
        return copy
    }

    public func remove(optionType: TransactionConfirmation.Kind) -> PendingTransaction {
        var copy = self
        copy.confirmations = confirmations.filter { $0.type != optionType }
        return copy
    }

    public static func == (lhs: PendingTransaction, rhs: PendingTransaction) -> Bool {
        lhs.amount == rhs.amount
            && lhs.available == rhs.available
            && lhs.fees == rhs.fees
            && lhs.selectedFiatCurrency == rhs.selectedFiatCurrency
            && lhs.feeLevel == rhs.feeLevel
            && lhs.confirmations == rhs.confirmations
            && lhs.minimumLimit == rhs.minimumLimit
            && lhs.minimumApiLimit == rhs.minimumApiLimit
            && lhs.maximumLimit == rhs.maximumLimit
            && lhs.validationState == rhs.validationState
    }

    /// The maximum amount the user can spend. We compare the amount entered to the
    /// `maximumLimit` as `CryptoValues` and return whichever is smaller.
    public var maxSpendable: MoneyValue {
        guard let maximumLimit = self.maximumLimit else {
            return available
        }
        guard let availableMaximumLimit = try? maximumLimit - fees else {
            return available
        }
        return (try? MoneyValue.min(available, availableMaximumLimit)) ?? .zero(currency: amount.currencyType)
    }
}

public extension PendingTransaction {
    static func zero(currencyType: CurrencyType) -> PendingTransaction {
        .init(
            amount: .zero(currency: currencyType),
            available: .zero(currency: currencyType),
            fees: .zero(currency: currencyType),
            feeLevel: .none,
            selectedFiatCurrency: .USD
        )
    }
}
