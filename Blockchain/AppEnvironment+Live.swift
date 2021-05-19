// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DebugUIKit
import DIKit

extension AppEnvironment {
    static var live: AppEnvironment {
        AppEnvironment(
            debugCoordinator: resolve(tag : DebugScreenContext.tag),
            onboardingSettings: resolve(),
            blurEffectHandler: .init(),
            appCoordinator: .shared,
            cacheSuite: resolve(),
            remoteNotificationServiceContainer: .default,
            certificatePinner: resolve(),
            siftService: resolve(),
            alertViewPresenter: resolve(),
            userActivityHandler: .init(),
            deeplinkAppHandler: .init(),
            backgroundAppHandler: .init(),
            dataProvider: .default,
            internalFeatureService: resolve(),
            appFeatureConfigurator: resolve(),
            blockchainSettings: .shared,
            credentialsStore: resolve()
        )
    }
}
