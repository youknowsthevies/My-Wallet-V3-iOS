// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import PlatformKit

extension DependencyContainer {

    // MARK: - FeatureInterestDomain Module

    public static var interestKit = module {

        single { InterestAccountService() as InterestAccountServiceAPI }

        factory { InterestTradingTransactionEngineFactory() as InterestTradingTransactionEngineFactoryAPI }

        factory { InterestOnChainTransactionEngineFactory() as InterestOnChainTransactionEngineFactoryAPI }

        factory { () -> InterestAccountOverviewAPI in
            let service: InterestAccountServiceAPI = DIKit.resolve()
            return service as InterestAccountOverviewAPI
        }
    }
}
