// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import ToolKit

struct InterestAccountOverviewBalanceSummary: Equatable, Identifiable {

    var id: String {
        currency.code + cryptoBalance + fiatBalance
    }

    let currency: CurrencyType
    let cryptoBalance: String
    let fiatBalance: String
}
