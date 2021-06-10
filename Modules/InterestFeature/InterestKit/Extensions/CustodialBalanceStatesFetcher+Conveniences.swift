// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

extension CustodialBalanceStatesFetcher {
    public convenience init(savingAccountService: SavingAccountServiceAPI,
                            scheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .background)) {
        self.init(
            custodialAccountType: .savings,
            fetch: { savingAccountService.balances(fetch: true) },
            scheduler: scheduler
        )
    }
}
