// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import PlatformUIKit
import RxDataSources

enum DashboardCellType: Hashable {
    case announcement(AnnouncementCardViewModel)
    case fiatCustodialBalances(CurrencyViewPresenter)
    case totalBalance(TotalBalanceViewPresenter)
    case notice(NoticeViewModel)
    case crypto(HistoricalBalanceCellPresenter)
    case cryptoSkeleton(Int)

    func hash(into hasher: inout Hasher) {
        hasher.combine(identity)
    }

    static func == (_ lhs: DashboardCellType, _ rhs: DashboardCellType) -> Bool {
        lhs.identity == rhs.identity
    }
}

extension DashboardCellType: IdentifiableType {
    var identity: AnyHashable {
        switch self {
        case .announcement(let model):
            let type = model.type
                .flatMap { "\($0)" } ?? ""
            return "announcement-\(type)"
        case .cryptoSkeleton(let id):
            return "cryptoSkeleton-\(id)"
        case .crypto(let presenter):
            return "crypto-\(presenter.cryptoCurrency.code)"
        case .fiatCustodialBalances:
            return "fiatCustodialBalances"
        case .notice:
            return "notice"
        case .totalBalance:
            return "totalBalance"
        }
    }
}
