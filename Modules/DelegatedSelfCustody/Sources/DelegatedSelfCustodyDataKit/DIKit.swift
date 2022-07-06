// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import NetworkKit

extension DependencyContainer {

    // MARK: - DelegatedSelfCustodyDataKit Module

    public static var delegatedSelfCustodyDataKit = module {

        factory {
            Client(
                networkAdapter: DIKit.resolve(tag: DIKitContext.retail),
                requestBuilder: DIKit.resolve(tag: DIKitContext.retail)
            ) as AccountDataClientAPI
        }

        single {
            DelegatedCustodyBalanceRepository(
                client: DIKit.resolve()
            ) as DelegatedCustodyBalanceRepository
        }
    }
}
