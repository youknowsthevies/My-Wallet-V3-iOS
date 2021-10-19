// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import DIKit
import ERC20Kit
import FeatureAuthenticationDomain
import FeatureDebugUI
import FeatureSettingsDomain
import NetworkKit
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import ToolKit
import WalletPayloadKit

public struct AppEnvironment {
    var loadingViewPresenter: LoadingViewPresenting
    var onboardingSettings: OnboardingSettingsAPI
    var blurEffectHandler: BlurVisualEffectHandlerAPI
    var cacheSuite: CacheSuite
    var remoteNotificationServiceContainer: RemoteNotificationServiceContaining
    var certificatePinner: CertificatePinnerAPI
    var siftService: SiftServiceAPI
    var alertViewPresenter: AlertViewPresenterAPI
    var deeplinkAppHandler: AppDeeplinkHandlerAPI
    var deeplinkHandler: DeepLinkHandling
    var deeplinkRouter: DeepLinkRouting
    var backgroundAppHandler: BackgroundAppHandlerAPI
    var portfolioSyncingService: BalanceSharingSettingsServiceAPI
    var mobileAuthSyncService: MobileAuthSyncServiceAPI
    var resetPasswordService: ResetPasswordServiceAPI
    var accountRecoveryService: AccountRecoveryServiceAPI
    var featureFlagsService: FeatureFlagsServiceAPI
    var internalFeatureService: InternalFeatureFlagServiceAPI // TODO: deprecated, use featureFlagsService instead
    var fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI
    var supportedAssetsRemoteService: SupportedAssetsRemoteServiceAPI
    var customerSupportChatService: CustomerSupportChatServiceAPI
    var sharedContainer: SharedContainerUserDefaults
    var analyticsRecorder: AnalyticsEventRecorderAPI

    var coincore: CoincoreAPI
    var erc20CryptoAssetService: ERC20CryptoAssetServiceAPI

    var walletManager: WalletManagerAPI
    var walletUpgradeService: WalletUpgradeServicing
    var exchangeRepository: ExchangeAccountRepositoryAPI

    var appFeatureConfigurator: FeatureConfiguratorAPI // TODO: deprecated, use featureFlagsService instead
    var blockchainSettings: BlockchainSettings.App
    var credentialsStore: CredentialsStoreAPI

    var urlSession: URLSession
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var appStoreOpener: AppStoreOpening
    var buildVersionProvider: () -> String

    public init(
        loadingViewPresenter: LoadingViewPresenting,
        onboardingSettings: OnboardingSettingsAPI,
        blurEffectHandler: BlurVisualEffectHandlerAPI,
        cacheSuite: CacheSuite,
        remoteNotificationServiceContainer: RemoteNotificationServiceContaining,
        certificatePinner: CertificatePinnerAPI,
        siftService: SiftServiceAPI,
        alertViewPresenter: AlertViewPresenterAPI,
        deeplinkAppHandler: AppDeeplinkHandlerAPI,
        deeplinkHandler: DeepLinkHandling,
        deeplinkRouter: DeepLinkRouting,
        backgroundAppHandler: BackgroundAppHandlerAPI,
        portfolioSyncingService: BalanceSharingSettingsServiceAPI,
        mobileAuthSyncService: MobileAuthSyncServiceAPI,
        resetPasswordService: ResetPasswordServiceAPI,
        accountRecoveryService: AccountRecoveryServiceAPI,
        featureFlagsService: FeatureFlagsServiceAPI,
        internalFeatureService: InternalFeatureFlagServiceAPI,
        fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI,
        supportedAssetsRemoteService: SupportedAssetsRemoteServiceAPI,
        customerSupportChatService: CustomerSupportChatServiceAPI,
        sharedContainer: SharedContainerUserDefaults,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        coincore: CoincoreAPI,
        erc20CryptoAssetService: ERC20CryptoAssetServiceAPI,
        walletManager: WalletManagerAPI,
        walletUpgradeService: WalletUpgradeServicing,
        exchangeRepository: ExchangeAccountRepositoryAPI,
        appFeatureConfigurator: FeatureConfiguratorAPI,
        blockchainSettings: BlockchainSettings.App,
        credentialsStore: CredentialsStoreAPI,
        urlSession: URLSession,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        appStoreOpener: AppStoreOpening,
        buildVersionProvider: @escaping () -> String
    ) {
        self.loadingViewPresenter = loadingViewPresenter
        self.onboardingSettings = onboardingSettings
        self.blurEffectHandler = blurEffectHandler
        self.cacheSuite = cacheSuite
        self.remoteNotificationServiceContainer = remoteNotificationServiceContainer
        self.certificatePinner = certificatePinner
        self.siftService = siftService
        self.alertViewPresenter = alertViewPresenter
        self.deeplinkAppHandler = deeplinkAppHandler
        self.deeplinkHandler = deeplinkHandler
        self.deeplinkRouter = deeplinkRouter
        self.backgroundAppHandler = backgroundAppHandler
        self.portfolioSyncingService = portfolioSyncingService
        self.mobileAuthSyncService = mobileAuthSyncService
        self.resetPasswordService = resetPasswordService
        self.accountRecoveryService = accountRecoveryService
        self.featureFlagsService = featureFlagsService
        self.internalFeatureService = internalFeatureService
        self.fiatCurrencySettingsService = fiatCurrencySettingsService
        self.supportedAssetsRemoteService = supportedAssetsRemoteService
        self.customerSupportChatService = customerSupportChatService
        self.sharedContainer = sharedContainer
        self.analyticsRecorder = analyticsRecorder
        self.coincore = coincore
        self.erc20CryptoAssetService = erc20CryptoAssetService
        self.walletManager = walletManager
        self.walletUpgradeService = walletUpgradeService
        self.exchangeRepository = exchangeRepository
        self.appFeatureConfigurator = appFeatureConfigurator
        self.blockchainSettings = blockchainSettings
        self.credentialsStore = credentialsStore
        self.urlSession = urlSession
        self.mainQueue = mainQueue
        self.appStoreOpener = appStoreOpener
        self.buildVersionProvider = buildVersionProvider
    }
}
