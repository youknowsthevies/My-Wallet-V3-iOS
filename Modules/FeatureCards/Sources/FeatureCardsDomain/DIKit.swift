// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    // MARK: - FeatureCardsDomain Module

    public static var featureCardsDomain = module {
        single { CardService() as CardServiceAPI }
        single { CardListService() as CardListServiceAPI }
        factory { CardUpdateService() as CardUpdateServiceAPI }
        factory { CardActivationService() as CardActivationServiceAPI }
        single { ApplePayAuthorizationService() as ApplePayAuthorizationServiceAPI }
        single {
            ApplePayService(
                repository: DIKit.resolve(),
                authorizationService: DIKit.resolve()
            ) as ApplePayServiceAPI
        }
    }
}
