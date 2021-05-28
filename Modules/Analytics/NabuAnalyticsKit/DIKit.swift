// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    // MARK: - NabuAnalyticsKit Module

    public static var nabuAnalyticsKit = module {

        single { ContextProvider() as ContextProviderAPI }

        single { TokenRepository() as TokenRepositoryAPI }

        single { AnalyticsEventService() as AnalyticsEventServiceAPI }
    }
}
