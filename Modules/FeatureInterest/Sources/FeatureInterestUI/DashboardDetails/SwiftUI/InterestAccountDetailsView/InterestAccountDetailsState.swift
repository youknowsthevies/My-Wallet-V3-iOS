// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureInterestDomain
import PlatformKit

struct InterestAccountDetailsState: Equatable {

    var interestAccountBalanceSummary: InterestAccountOverviewBalanceSummary?
    var interestAccountRowItems: IdentifiedArrayOf<InterestAccountOverviewRowItem> {
        IdentifiedArrayOf(uniqueElements: interestAccountOverview.items)
    }

    var interestAccountOverview: InterestAccountOverview

    init(interestAccountOverview: InterestAccountOverview) {
        self.interestAccountOverview = interestAccountOverview
    }
}
