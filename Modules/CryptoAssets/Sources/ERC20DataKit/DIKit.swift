// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ERC20Kit

extension DependencyContainer {

    // MARK: - ERC20DataKit Module

    public static var erc20DataKit = module {

        factory {
            ERC20AccountClient(
                apiCode: DIKit.resolve(),
                networkAdapter: DIKit.resolve(),
                requestBuilder: DIKit.resolve()
            ) as ERC20AccountClientAPI
        }

        single {
            ERC20TokenAccountsRepository(
                client: DIKit.resolve(),
                enabledCurrenciesService: DIKit.resolve()
            ) as ERC20TokenAccountsRepositoryAPI
        }
    }
}
