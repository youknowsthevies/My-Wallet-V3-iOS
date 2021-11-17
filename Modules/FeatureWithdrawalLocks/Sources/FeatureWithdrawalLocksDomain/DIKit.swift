// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    public static var withdrawalLocksDomain = module {

        factory { WithdrawalLocksService() as WithdrawalLocksServiceAPI }
    }
}
