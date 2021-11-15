// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import NabuNetworkError
import PlatformKit

public enum TransactionValidationState: Equatable {
    /// The transaction has not been initialized yet
    case uninitialized
    /// The transaction is valid and can be executed
    case canExecute
    /// Any other error
    case unknownError
    /// represents a raw error from backend
    case nabuError(NabuError)
    /// Takes the balance of the transaction's source in the input currency, the source currency and the target currency
    case insufficientFunds(MoneyValue, CurrencyType, CurrencyType)
    /// Takes the minimum valid amount required to execute the transaction.
    case belowMinimumLimit(MoneyValue)
    /// The amount is above the maximum allowed for this transaction for the specific source.
    /// Takes the maximum limit, the account name, and the desired amount.
    case overMaximumSourceLimit(MoneyValue, String, MoneyValue)
    /// The amount is over the user's maximum limit for the transaction.
    /// Takes the applicable Periodic Limit that has been exceeded, the available limit, and an optional suggested upgrade.
    case overMaximumPersonalLimit(EffectiveLimit, MoneyValue, SuggestedLimitsUpgrade?)

    // MARK: - Not checked

    case overMaximumLimit // TODO: DELETE ME. Should use overMaximumPersonalLimit or overMaximumSourceLimit.
    case noSourcesAvailable
    case addressIsContract
    case insufficientGas
    case invalidAddress
    case invalidAmount
    case insufficientFundsForFees
    case invoiceExpired
    case optionInvalid
    case pendingOrdersLimitReached
    case transactionInFlight
}
