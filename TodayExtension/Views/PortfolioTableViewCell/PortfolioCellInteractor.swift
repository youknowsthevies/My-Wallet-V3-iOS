// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

final class PortfolioCellInteractor {

    let balanceFiatValue: FiatValue
    let changeFiatValue: FiatValue
    let delta: String
    let isPositive: Bool

    init(portfolio: Portfolio) {
        let balanceChange = portfolio.balanceChange
        self.isPositive = balanceChange.changePercentage >= .zero
        self.balanceFiatValue = portfolio.balanceFiatValue
        self.changeFiatValue = portfolio.changeFiatValue
        let percentage = balanceChange.changePercentage * 100
        let percentageString = percentage.string(with: 2)
        self.delta = "(\(percentageString)%)"
    }
}
