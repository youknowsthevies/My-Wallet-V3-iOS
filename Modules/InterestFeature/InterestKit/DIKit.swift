// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit

extension DependencyContainer {

    // MARK: - InterestKit Module

    public static var interestKit = module {
        factory { SavingsAccountClient() as SavingsAccountClientAPI }

        factory { SavingAccountService() as SavingAccountServiceAPI }

        factory { SavingAccountService() as SavingsOverviewAPI }
    }
}
