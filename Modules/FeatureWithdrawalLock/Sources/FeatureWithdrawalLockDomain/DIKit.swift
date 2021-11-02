// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    public static var withdrawalLockDomain = module {

        factory { APIClient() as WithdrawalLocksClientAPI }

        factory { WithdrawalLocksRepository() as WithdrawalLocksRepositoryAPI }

        single { WithdrawalLocksUseCase() as WithdrawalLocksUseCaseAPI }
    }
}
