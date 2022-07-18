// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit

extension DependencyContainer {

    public static var featureActivityDomain = module {

        factory { TransactionDetailService() as TransactionDetailServiceAPI }

        factory { ActivityServiceContainer() as ActivityServiceContaining }

        // MARK: Public

        factory {
            BuySellActivityItemEventService(
                ordersService: DIKit.resolve(),
                kycTiersService: DIKit.resolve()
            ) as BuySellActivityItemEventServiceAPI
        }
    }
}
