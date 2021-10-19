// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureInterestDomain
import Localization

extension InterestAccountOverview {

    private typealias AccountDetails = LocalizationConstants.Interest.Screen.AccountDetails
    private typealias LocalizationId = AccountDetails.Cell.Default

    var items: [InterestAccountOverviewRowItem] {
        let total = InterestAccountOverviewRowItem(
            title: LocalizationId.Total.title,
            description: totalEarned.displayString
        )
        let next = InterestAccountOverviewRowItem(
            title: LocalizationId.Next.title,
            description: nextPaymentDate
        )
        let accrued = InterestAccountOverviewRowItem(
            title: LocalizationId.Accrued.title,
            description: accrued.displayString
        )
        let rate = InterestAccountOverviewRowItem(
            title: LocalizationId.Rate.title,
            description: "\(interestAccountRate.rate)%"
        )
        return [
            total,
            next,
            accrued,
            rate
        ]
    }
}
