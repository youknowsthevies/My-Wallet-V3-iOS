// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import StellarKit

struct StellarServices: StellarDependenciesAPI {
    let accounts: StellarAccountAPI

    init(
        repository: StellarWalletAccountRepositoryAPI = resolve()
    ) {
        accounts = StellarAccountService(
            repository: repository
        )
    }
}
