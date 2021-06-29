// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

public enum LinkedBankAccountType {
    case savings
    case checking
}

public extension LinkedBankAccountType {
    var title: String {
        switch self {
        case .checking:
            return LocalizationConstants.Transaction.checking
        case .savings:
            return LocalizationConstants.Transaction.savings
        }
    }
}

extension LinkedBankAccountType {
    init(from type: LinkedBankResponse.AccountType) {
        switch type {
        case .savings:
            self = .savings
        case .checking:
            self = .checking
        }
    }
}
