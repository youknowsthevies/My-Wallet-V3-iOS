//
//  ActivityItemInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 16/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit

final class ActivityItemInteractor {
    
    let balanceViewInteracting: ActivityItemBalanceViewInteractor
    let event: ActivityItemEvent
    
    init(exchangeAPI: PairExchangeServiceAPI,
         activityItemEvent: ActivityItemEvent) {
        self.event = activityItemEvent
        balanceViewInteracting = .init(
            activityItemBalanceFetching: ActivityItemBalanceFetcher(
                exchange: exchangeAPI,
                cryptoValue: activityItemEvent.amount
            )
        )
    }
}
