// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum WalletPickerSelection {
    case all
    case nonCustodial(CurrencyType)
    case custodial(CurrencyType)

    public var currencyType: CurrencyType? {
        switch self {
        case .nonCustodial(let currency),
             .custodial(let currency):
            return currency
        case .all:
            return nil
        }
    }
}

extension WalletPickerSelection: Equatable {
    public static func ==(lhs: WalletPickerSelection, rhs: WalletPickerSelection) -> Bool {
        switch (lhs, rhs) {
        case (.nonCustodial(let left), .nonCustodial(let right)):
            return left == right
        case (.custodial(let left), .custodial(let right)):
            return left == right
        case (.all, .all):
            return true
        default:
            return false
        }
    }
}
