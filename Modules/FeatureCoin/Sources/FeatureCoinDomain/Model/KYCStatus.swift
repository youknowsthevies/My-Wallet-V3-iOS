// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum KYCStatus: Equatable {
    case unverified
    case inReview
    case silver
    case silverPlus
    case gold

    public var canPurchaseCrypto: Bool {
        switch self {
        case .unverified, .silver:
            return false
        case .silverPlus, .gold, .inReview:
            return true
        }
    }
}
