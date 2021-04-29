// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit

final class ActivityItemInteractor {
    
    let balanceViewInteractor: AssetBalanceViewInteracting
    let event: ActivityItemEvent
    
    init(exchangeAPI: PairExchangeServiceAPI,
         assetBalanceFetcher: AssetBalanceFetching,
         activityItemEvent: ActivityItemEvent) {
        self.event = activityItemEvent
        balanceViewInteractor = ActivityItemBalanceViewInteractor.init(
            activityItemBalanceFetching: ActivityItemBalanceFetcher(
                exchange: exchangeAPI,
                moneyValue: event.amount
            )
        )
    }
}
