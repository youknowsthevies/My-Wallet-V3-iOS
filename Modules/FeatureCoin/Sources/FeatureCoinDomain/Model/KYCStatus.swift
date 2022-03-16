// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum KYCStatus: Equatable {
    case unverified
    case inReview
    case silver
    case silverPlus
    case gold

    public var canSellCrypto: Bool {
        switch self {
        case .unverified, .silver, .inReview:
            return false
        case .silverPlus, .gold:
            return true
        }
    }
}
