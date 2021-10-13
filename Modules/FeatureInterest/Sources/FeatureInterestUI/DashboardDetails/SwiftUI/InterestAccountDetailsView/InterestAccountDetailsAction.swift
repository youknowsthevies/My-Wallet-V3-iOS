// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

enum InterestAccountDetailsAction: Equatable {
    case loadInterestAccountBalanceInfo
    case interestAccountFiatBalanceFetchFailed
    case interestAccountFiatBalanceFetched(MoneyValue)
    case startInterestDeposit
    case startInterestWithdraw
    case closeButtonTapped
    case interestAccountDescriptorTapped(
        id: InterestAccountOverviewRowItem.ID,
        action: InterestAccountDetailsRowAction
    )
}
