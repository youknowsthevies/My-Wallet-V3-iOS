// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    // MARK: - MoneyKit Module

    public static var moneyKit = module {

        single {
            EnabledCurrenciesService(
                polygonSupport: DIKit.resolve(),
                repository: DIKit.resolve()
            ) as EnabledCurrenciesServiceAPI
        }

        factory { SupportedAssetsFilePathProvider() as SupportedAssetsFilePathProviderAPI }

        factory { SupportedAssetsService() as SupportedAssetsServiceAPI }

        single { SupportedAssetsRepository() as SupportedAssetsRepositoryAPI }
    }
}
