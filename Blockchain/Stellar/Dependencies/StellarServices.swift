// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import StellarKit

struct StellarServices: StellarDependenciesAPI {
    let accounts: StellarAccountAPI

    init(
        configurationService: StellarConfigurationAPI = resolve(),
        repository: StellarWalletAccountRepositoryAPI = resolve()
    ) {
        accounts = StellarAccountService(
            configurationService: configurationService,
            repository: repository
        )
    }
}
