// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureWithdrawalLocksDomain

extension DependencyContainer {

    public static var withdrawalLocksData = module {

        factory { APIClient() as WithdrawalLocksClientAPI }

        factory { WithdrawalLocksRepository() as WithdrawalLocksRepositoryAPI }
    }
}
