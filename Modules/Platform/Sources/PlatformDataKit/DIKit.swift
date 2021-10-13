// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import PlatformKit

extension DependencyContainer {

    // MARK: - PlatformKit Module

    public static var platformDataKit = module {

        // MARK: - Interest

        factory { APIClient() as PlatformDataAPIClient }

        factory { () -> InterestAccountEligibilityClientAPI in
            let client: PlatformDataAPIClient = DIKit.resolve()
            return client as InterestAccountEligibilityClientAPI
        }

        factory { InterestAccountEligibilityRepository() as InterestAccountEligibilityRepositoryAPI }

        // MARK: - Price

        factory { () -> PriceClientAPI in
            let client: PlatformDataAPIClient = DIKit.resolve()
            return client as PriceClientAPI
        }

        single { PriceRepository() as PriceRepositoryAPI }
    }
}
