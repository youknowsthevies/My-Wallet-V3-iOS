// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DebugUIKit
import DIKit
import NetworkKit
import PlatformKit
import PlatformUIKit
import ToolKit

public struct AppEnvironment {
    public var debugCoordinator: DebugCoordinating

    var onboardingSettings: OnboardingSettings
    var blurEffectHandler: BlurVisualEffectHandler
    var appCoordinator: AppCoordinator
    var cacheSuite: CacheSuite
    var remoteNotificationServiceContainer: RemoteNotificationServiceContainer
    var certificatePinner: CertificatePinnerAPI
    var siftService: SiftServiceAPI
    var alertViewPresenter: AlertViewPresenterAPI
    var userActivityHandler: UserActivityHandler
    var deeplinkAppHandler: DeeplinkAppHandler
    var backgroundAppHandler: BackgroundAppHandler
    var dataProvider: DataProvider
}

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
            dataProvider: .default
        )
    }
}
