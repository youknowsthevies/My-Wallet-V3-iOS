// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension TransactionErrorState {

    private typealias Localization = LocalizationConstants.Transaction.Error

    var shortDescription: String {
        let text: String
        switch self {
        case .none:
            text = "" // no error
        case .addressIsContract:
            text = Localization.addressIsContractShort
        case .insufficientFunds:
            text = Localization.insufficientFundsShort
        case .insufficientGas:
            text = Localization.insufficientGasShort
        case .insufficientFundsForFees:
            text = Localization.insufficientFundsForFeesShort
        case .invalidAddress:
            text = Localization.invalidAddressShort
        case .invalidAmount:
            text = Localization.invalidAmountShort
        case .invalidPassword:
            text = Localization.invalidPasswordShort
        case .optionInvalid:
            text = Localization.optionInvalidShort
        case .belowMinimumLimit:
            text = Localization.belowMinimumLimitShort
        case .overGoldTierLimit,
             .overSilverTierLimit,
             .overMaximumLimit:
            text = Localization.overMaximumLimitShort
        case .pendingOrdersLimitReached:
            text = Localization.pendingOrdersLimitReachedShort
        case .transactionInFlight:
            text = Localization.transactionInFlightShort
        case .unknownError:
            text = Localization.unknownErrorShort
        case .fatalError:
            text = Localization.fatalErrorShort
        case .nabuError:
            text = Localization.nextworkErrorShort
        }
        return text
    }
}
