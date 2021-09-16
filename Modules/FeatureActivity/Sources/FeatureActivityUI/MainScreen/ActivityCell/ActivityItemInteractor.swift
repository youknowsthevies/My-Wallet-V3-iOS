// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit

final class ActivityItemInteractor {

    let event: ActivityItemEvent
    let balanceViewInteractor: AssetBalanceViewInteracting

    init(activityItemEvent: ActivityItemEvent, pairExchangeService: PairExchangeServiceAPI) {
        event = activityItemEvent
        balanceViewInteractor = ActivityItemBalanceViewInteractor(
            activityItemBalanceFetching: ActivityItemBalanceFetcher(
                pairExchangeService: pairExchangeService,
                moneyValue: activityItemEvent.amount
            )
        )
    }
}
