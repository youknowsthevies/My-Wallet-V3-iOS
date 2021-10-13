// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureInterestDomain

extension DependencyContainer {

    // MARK: - FeatureInterestData Module

    public static var interestDataKit = module {

        // MARK: - Data

        factory { APIClient() as FeatureInterestDataAPIClient }

        factory { () -> InterestAccountBalanceClientAPI in
            let client: FeatureInterestDataAPIClient = DIKit.resolve()
            return client as InterestAccountBalanceClientAPI
        }

        factory { () -> InterestAccountLimitsClientAPI in
            let client: FeatureInterestDataAPIClient = DIKit.resolve()
            return client as InterestAccountLimitsClientAPI
        }

        factory { () -> InterestAccountRateClientAPI in
            let client: FeatureInterestDataAPIClient = DIKit.resolve()
            return client as InterestAccountRateClientAPI
        }

        factory { InterestAccountOverviewRepository() as InterestAccountOverviewRepositoryAPI }

        factory { InterestAccountLimitsRepository() as InterestAccountLimitsRepositoryAPI }

        single { InterestAccountBalanceRepository() as InterestAccountBalanceRepositoryAPI }

        factory { InterestAccountRateRepository() as InterestAccountRateRepositoryAPI }
    }
}
