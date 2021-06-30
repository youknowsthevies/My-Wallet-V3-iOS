// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DebugUIKit
import DIKit
import PlatformKit

extension AppEnvironment {
    static var live: AppEnvironment {
        AppEnvironment(
            debugCoordinator: resolve(tag : DebugScreenContext.tag),
            loadingViewPresenter: resolve(),
            onboardingSettings: resolve(),
            blurEffectHandler: .init(),
            appCoordinator: .shared,
            cacheSuite: resolve(),
            remoteNotificationServiceContainer: resolve(),
            certificatePinner: resolve(),
            siftService: resolve(),
            alertViewPresenter: resolve(),
            deeplinkAppHandler: resolve(),
            deeplinkHandler: resolve(),
            deeplinkRouter: resolve(),
            backgroundAppHandler: .init(),
            portfolioSyncingService: resolve(),
            internalFeatureService: resolve(),
            fiatCurrencySettingsService: resolve(),
            sharedContainer: .default,
            analyticsRecorder: resolve(),
            coincore: resolve(),
            walletManager: .shared,
            walletUpgradeService: resolve(),
            exchangeRepository: ExchangeAccountRepository(),
            appFeatureConfigurator: resolve(),
            blockchainSettings: .shared,
            credentialsStore: resolve(),
            mainQueue: .main
        )
    }
}
