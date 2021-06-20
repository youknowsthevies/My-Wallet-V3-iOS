// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DebugUIKit
import DIKit
import PlatformKit

extension AppEnvironment {
    static var live: AppEnvironment {
        AppEnvironment(
            debugCoordinator: resolve(tag : DebugScreenContext.tag),
            onboardingSettings: resolve(),
            blurEffectHandler: .init(),
            appCoordinator: .shared,
            cacheSuite: resolve(),
            remoteNotificationServiceContainer: resolve(),
            certificatePinner: resolve(),
            siftService: resolve(),
            alertViewPresenter: resolve(),
            userActivityHandler: .init(),
            deeplinkAppHandler: .init(),
            backgroundAppHandler: .init(),
            portfolioSyncingService: resolve(),
            internalFeatureService: resolve(),
            sharedContainer: .default,
            analyticsRecorder: resolve(),
            coincore: resolve(),
            walletManager: .shared,
            walletUpgradeService: resolve(),
            exchangeRepository: ExchangeAccountRepository(),
            appFeatureConfigurator: resolve(),
            blockchainSettings: .shared,
            credentialsStore: resolve()
        )
    }
}
