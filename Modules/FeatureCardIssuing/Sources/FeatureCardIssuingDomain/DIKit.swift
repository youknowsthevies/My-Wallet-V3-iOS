// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    // MARK: - FeatureCardIssuingDomain Module

    public static var featureCardIssuingDomain = module {

        factory {
            CardService(
                repository: DIKit.resolve()
            ) as CardServiceAPI
        }

        factory {
            ProductsService(
                repository: DIKit.resolve()
            ) as ProductsServiceAPI
        }

        factory {
            RewardsService(
                repository: DIKit.resolve()
            ) as RewardsServiceAPI
        }
    }
}
