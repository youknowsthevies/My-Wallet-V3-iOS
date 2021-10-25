// Copyright © Blockchain Luxembourg S.A. All rights reserved.
import NabuNetworkError

public enum TransactionValidationState: Equatable {
    case uninitialized
    case noSourcesAvailable
    case addressIsContract
    case belowMinimumLimit
    case canExecute
    case insufficientFunds
    case insufficientGas
    case invalidAddress
    case invalidAmount
    case insufficientFundsForFees
    case invoiceExpired
    case optionInvalid
    case overGoldTierLimit
    case overMaximumLimit
    case overSilverTierLimit
    case pendingOrdersLimitReached
    case transactionInFlight
    case unknownError
    /// represents a raw error from backend
    case nabuError(NabuError)
}
