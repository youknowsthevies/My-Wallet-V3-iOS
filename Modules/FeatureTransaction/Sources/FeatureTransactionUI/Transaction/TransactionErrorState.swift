// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import NabuNetworkError
import PlatformKit

enum TransactionErrorState: Equatable {
    /// The tansaction is valid
    case none
    /// Any other error
    case unknownError
    /// A network error
    case nabuError(NabuError)
    /// The balance of the source account is not sufficient to execute the transaction.
    /// Takes the balance of the transaction's source in the input currency, the source currency and the target currency.
    case insufficientFunds(MoneyValue, CurrencyType, CurrencyType)
    /// The amount is below the user's minimum limit for the transaction.
    /// Takes the minimum valid amount required to execute the transaction.
    case belowMinimumLimit(MoneyValue)
    /// The amount is over the maximum allowed for this transaction for the specific source.
    /// Takes the maximum limit, the account name, and the desired amount.
    case overMaximumSourceLimit(MoneyValue, String, MoneyValue)
    /// The amount is over the user's maximum limit for the transaction.
    /// Takes the applicable Periodic Limit that has been exceeded, the available limit, and an optional suggested upgrade.
    case overMaximumPersonalLimit(EffectiveLimit, MoneyValue, SuggestedLimitsUpgrade?)

    // MARK: - Not checked

    case overMaximumLimit // TODO: DELETE ME. Should use overMaximumPersonalLimit or overMaximumSourceLimit.
    case addressIsContract
    case insufficientGas
    case insufficientFundsForFees
    case invalidAddress
    case invalidAmount
    case invalidPassword
    case optionInvalid
    case pendingOrdersLimitReached
    case transactionInFlight
    case fatalError(FatalTransactionError)
}

extension TransactionErrorState {
    var fatalError: FatalTransactionError? {
        switch self {
        case .fatalError(let error):
            return error
        default:
            return nil
        }
    }
}
