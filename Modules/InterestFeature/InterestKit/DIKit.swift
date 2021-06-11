// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit

extension DependencyContainer {

    // MARK: - InterestKit Module

    public static var interestKit = module {

        factory { SavingsAccountClient() as SavingsAccountClientAPI }

        single { SavingAccountService() as SavingAccountServiceAPI }

        factory { () -> SavingsOverviewAPI in
            let service: SavingAccountServiceAPI = DIKit.resolve()
            return service as SavingsOverviewAPI
        }
    }
}
