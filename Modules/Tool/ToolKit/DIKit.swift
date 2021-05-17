// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    // MARK: - ToolKit Module

    public static var toolKit = module {

        factory { UserDefaults.standard as CacheSuite }

        // MARK: - Internal Feature Flag

        factory { InternalFeatureFlagService(defaultsProvider: provideInternalUserDefaults) as InternalFeatureFlagServiceAPI }
    }
}
