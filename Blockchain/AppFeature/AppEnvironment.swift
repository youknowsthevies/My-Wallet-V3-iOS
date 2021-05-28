// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DebugUIKit
import DIKit
import NetworkKit
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import SettingsKit
import ToolKit

public struct AppEnvironment {
    public var debugCoordinator: DebugCoordinating

    var onboardingSettings: OnboardingSettings
    var blurEffectHandler: BlurVisualEffectHandler
    var appCoordinator: AppCoordinator
    var cacheSuite: CacheSuite
    var remoteNotificationServiceContainer: RemoteNotificationServiceContaining
    var certificatePinner: CertificatePinnerAPI
    var siftService: SiftServiceAPI
    var alertViewPresenter: AlertViewPresenterAPI
    var userActivityHandler: UserActivityHandler
    var deeplinkAppHandler: DeeplinkAppHandler
    var backgroundAppHandler: BackgroundAppHandler
    var dataProvider: DataProvider
    var internalFeatureService: InternalFeatureFlagServiceAPI

    var appFeatureConfigurator: AppFeatureConfigurator
    var blockchainSettings: BlockchainSettings.App
    var credentialsStore: CredentialsStoreAPI
}
