// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import RxDataSources

enum DashboardCellType: Hashable {
    case announcement
    case fiatCustodialBalances
    case totalBalance
    case notice
    case crypto(CryptoCurrency)
}

extension DashboardCellType: IdentifiableType {
    var identity: AnyHashable {
        switch self {
        case .announcement:
            return "announcement"
        case .crypto(let coin):
            return "crypto-\(coin.code)"
        case .fiatCustodialBalances:
            return "fiatCustodialBalances"
        case .notice:
            return "notice"
        case .totalBalance:
            return "totalBalance"
        }
    }
}
