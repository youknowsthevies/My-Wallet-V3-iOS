// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ERC20Kit
import PlatformKit

enum SendMoniesInternalError: Error {
    /// `insufficientFeeCoverage` is also
    /// insufficient ethereum balance.
    case insufficientFeeCoverage
    case insufficientTokenBalance
    case invalidDestinationAddress
    case pendingTransaction
    case `default`
    
    init(erc20error: ERC20EvaluationError) {
        if let value = erc20error as? ERC20ValidationError {
            switch value {
            case .pendingTransaction:
                self = .pendingTransaction
            case .insufficientEthereumBalance:
                self = .insufficientFeeCoverage
            case .insufficientTokenBalance:
                self = .insufficientTokenBalance
            case .invalidCryptoValue:
                self = .default
            case .cryptoValueBelowMinimumSpendable:
                self = .default
            }
        } else if let value = erc20error as? ERC20ServiceError {
            switch value {
            case .invalidEthereumAddress:
                self = .invalidDestinationAddress
            }
        } else {
            self = .default
        }
    }
}

extension SendMoniesInternalError {
    var title: String {
        switch self {
        case .insufficientFeeCoverage:
            return LocalizationConstants.SendAsset.notEnoughEth
        case .insufficientTokenBalance:
            return String(format: "\(LocalizationConstants.SendAsset.notEnough) %@", CryptoCurrency.pax.name)
        case .invalidDestinationAddress:
            return LocalizationConstants.SendAsset.invalidDestinationAddress
        case .pendingTransaction:
            return LocalizationConstants.SendEther.waitingForPaymentToFinishTitle
        case .default:
            return LocalizationConstants.Errors.error
        }
    }
    
    var description: String? {
        switch self {
        case .insufficientFeeCoverage:
            return String(format: "\(LocalizationConstants.SendAsset.notEnoughEthDescription), %@.", CryptoCurrency.pax.name)
        case .insufficientTokenBalance:
            return String(format: "\(LocalizationConstants.SendAsset.notEnough) %@", CryptoCurrency.pax.name)
        case .invalidDestinationAddress:
            return LocalizationConstants.SendAsset.invalidDestinationDescription
        case .pendingTransaction:
            return LocalizationConstants.SendEther.waitingForPaymentToFinishMessage
        case .default:
            return LocalizationConstants.Errors.error
        }
    }
}
