// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DIKit
import FeatureAppUI
import FeatureDebugUI
import PlatformKit
import ToolKit
import WalletPayloadKit

extension AppEnvironment {

    static var live: AppEnvironment {
        AppEnvironment(
            app: resolve(),
            nabuUserService: resolve(),
            loadingViewPresenter: resolve(),
            blurEffectHandler: resolve(),
            cacheSuite: resolve(),
            remoteNotificationServiceContainer: resolve(),
            certificatePinner: resolve(),
            siftService: resolve(),
            alertViewPresenter: resolve(),
            deeplinkAppHandler: resolve(),
            deeplinkHandler: resolve(),
            deeplinkRouter: resolve(),
            backgroundAppHandler: resolve(),
            mobileAuthSyncService: resolve(),
            pushNotificationsRepository: resolve(),
            resetPasswordService: resolve(),
            accountRecoveryService: resolve(),
            userService: resolve(),
            deviceVerificationService: resolve(),
            featureFlagsService: resolve(),
            fiatCurrencySettingsService: resolve(),
            supportedAssetsRemoteService: resolve(),
            sharedContainer: .default,
            customerSupportChatService: resolve(),
            analyticsRecorder: resolve(),
            crashlyticsRecorder: resolve(tag: "CrashlyticsRecorder"),
            openBanking: resolve(),
            cardService: resolve(),
            coincore: resolve(),
            erc20CryptoAssetService: resolve(),
            walletService: .live(
                fetcher: DIKit.resolve(),
                recovery: DIKit.resolve()
            ),
            forgetWalletService: .live(forgetWallet: DIKit.resolve()),
            walletPayloadService: resolve(),
            walletManager: resolve(),
            walletUpgradeService: resolve(),
            walletRepoPersistence: resolve(),
            exchangeRepository: ExchangeAccountRepository(),
            blockchainSettings: .shared,
            credentialsStore: resolve(),
            urlSession: resolve(),
            mainQueue: .main,
            appStoreOpener: resolve(),
            secondPasswordPrompter: resolve(),
            buildVersionProvider: Bundle.versionAndBuildNumber,
            externalAppOpener: resolve(),
            observabilityService: resolve(),
            performanceTracing: resolve(),
            deviceInfo: resolve()
        )
    }
}
