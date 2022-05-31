// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import stellarsdk

public enum StellarAccountError: Error {
    case unableToSaveNewAccount
}

public enum StellarNetworkError: Error {
    case notFound
    case parsingFailed
    case destinationRequiresMemo
    case horizonRequestError(Error)
}

extension HorizonRequestError {
    public var stellarNetworkError: StellarNetworkError {
        switch self {
        case .notFound:
            return .notFound
        case .parsingResponseFailed:
            return .parsingFailed
        default:
            return .horizonRequestError(self)
        }
    }
}
