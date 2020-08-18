//
//  CustodialBalanceStatesFetcher+Conveniences.swift
//  InterestKit
//
//  Created by Alex McGregor on 8/6/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

extension CustodialBalanceStatesFetcher {
    public convenience init(savingAccountService: SavingAccountServiceAPI,
                            scheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .background)) {
        self.init(
            custodialType: .savings,
            fetch: { savingAccountService.fetchBalances() },
            scheduler: scheduler
        )
    }
}

