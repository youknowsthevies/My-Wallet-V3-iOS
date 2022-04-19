// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import ComposableArchitecture
import DIKit
import ERC20Kit
import FeatureAppDomain
import FeatureAuthenticationDomain
import FeatureAuthenticationUI
import FeatureCardPaymentDomain
import FeatureDebugUI
import FeatureOpenBankingDomain
import FeatureSettingsDomain
import NetworkKit
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import ToolKit
import WalletPayloadKit

public struct AppEnvironment {
    var app: AppProtocol
    var nabuUserService: NabuUserServiceAPI
    var loadingViewPresenter: LoadingViewPresenting
    var onboardingSettings: OnboardingSettingsAPI
    var blurEffectHandler: BlurVisualEffectHandlerAPI
    var cacheSuite: CacheSuite
    var remoteNotificationServiceContainer: RemoteNotificationServiceContaining
    var certificatePinner: CertificatePinnerAPI
    var siftService: FeatureAuthenticationDomain.SiftServiceAPI
    var alertViewPresenter: AlertViewPresenterAPI
    var deeplinkAppHandler: AppDeeplinkHandlerAPI
    var deeplinkHandler: DeepLinkHandling
    var deeplinkRouter: DeepLinkRouting
    var backgroundAppHandler: BackgroundAppHandlerAPI
    var mobileAuthSyncService: MobileAuthSyncServiceAPI
    var pushNotificationsRepository: PushNotificationsRepositoryAPI
    var resetPasswordService: ResetPasswordServiceAPI
    var accountRecoveryService: AccountRecoveryServiceAPI
    var userService: NabuUserServiceAPI
    var deviceVerificationService: DeviceVerificationServiceAPI
    var featureFlagsService: FeatureFlagsServiceAPI
    var fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI
    var supportedAssetsRemoteService: SupportedAssetsRemoteServiceAPI
    var sharedContainer: SharedContainerUserDefaults
    var customerSupportChatService: CustomerSupportChatServiceAPI
    var analyticsRecorder: AnalyticsEventRecorderAPI
    var crashlyticsRecorder: Recording
    var openBanking: OpenBanking
    var cardService: CardServiceAPI

    var coincore: CoincoreAPI
    var erc20CryptoAssetService: ERC20CryptoAssetServiceAPI

    var walletService: WalletService
    var forgetWalletService: ForgetWalletService
    var walletPayloadService: WalletPayloadServiceAPI
    var secondPasswordPrompter: SecondPasswordPromptable

    var walletManager: WalletManagerAPI
    var walletUpgradeService: WalletUpgradeServicing
    var walletRepoPersistence: WalletRepoPersistenceAPI
    var exchangeRepository: ExchangeAccountRepositoryAPI

    var blockchainSettings: BlockchainSettings.App
    var credentialsStore: CredentialsStoreAPI

    var urlSession: URLSession
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var appStoreOpener: AppStoreOpening
    var buildVersionProvider: () -> String
    var externalAppOpener: ExternalAppOpener

    @available(*, deprecated, message: "Use featureFlagsService instead")
    var internalFeatureService: InternalFeatureFlagServiceAPI
    @available(*, deprecated, message: "Use featureFlagsService instead")
    var appFeatureConfigurator: FeatureConfiguratorAPI

    public init(
        app: AppProtocol,
        nabuUserService: NabuUserServiceAPI,
        loadingViewPresenter: LoadingViewPresenting,
        onboardingSettings: OnboardingSettingsAPI,
        blurEffectHandler: BlurVisualEffectHandlerAPI,
        cacheSuite: CacheSuite,
        remoteNotificationServiceContainer: RemoteNotificationServiceContaining,
        certificatePinner: CertificatePinnerAPI,
        siftService: FeatureAuthenticationDomain.SiftServiceAPI,
        alertViewPresenter: AlertViewPresenterAPI,
        deeplinkAppHandler: AppDeeplinkHandlerAPI,
        deeplinkHandler: DeepLinkHandling,
        deeplinkRouter: DeepLinkRouting,
        backgroundAppHandler: BackgroundAppHandlerAPI,
        mobileAuthSyncService: MobileAuthSyncServiceAPI,
        pushNotificationsRepository: PushNotificationsRepositoryAPI,
        resetPasswordService: ResetPasswordServiceAPI,
        accountRecoveryService: AccountRecoveryServiceAPI,
        userService: NabuUserServiceAPI,
        deviceVerificationService: DeviceVerificationServiceAPI,
        featureFlagsService: FeatureFlagsServiceAPI,
        internalFeatureService: InternalFeatureFlagServiceAPI,
        fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI,
        supportedAssetsRemoteService: SupportedAssetsRemoteServiceAPI,
        sharedContainer: SharedContainerUserDefaults,
        customerSupportChatService: CustomerSupportChatServiceAPI,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        crashlyticsRecorder: Recording,
        openBanking: OpenBanking,
        cardService: CardServiceAPI,
        coincore: CoincoreAPI,
        erc20CryptoAssetService: ERC20CryptoAssetServiceAPI,
        walletService: WalletService,
        forgetWalletService: ForgetWalletService,
        walletPayloadService: WalletPayloadServiceAPI,
        walletManager: WalletManagerAPI,
        walletUpgradeService: WalletUpgradeServicing,
        walletRepoPersistence: WalletRepoPersistenceAPI,
        exchangeRepository: ExchangeAccountRepositoryAPI,
        appFeatureConfigurator: FeatureConfiguratorAPI,
        blockchainSettings: BlockchainSettings.App,
        credentialsStore: CredentialsStoreAPI,
        urlSession: URLSession,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        appStoreOpener: AppStoreOpening,
        secondPasswordPrompter: SecondPasswordPromptable,
        buildVersionProvider: @escaping () -> String,
        externalAppOpener: ExternalAppOpener
    ) {
        self.app = app
        self.nabuUserService = nabuUserService
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
        self.mobileAuthSyncService = mobileAuthSyncService
        self.pushNotificationsRepository = pushNotificationsRepository
        self.resetPasswordService = resetPasswordService
        self.accountRecoveryService = accountRecoveryService
        self.userService = userService
        self.deviceVerificationService = deviceVerificationService
        self.featureFlagsService = featureFlagsService
        self.internalFeatureService = internalFeatureService
        self.fiatCurrencySettingsService = fiatCurrencySettingsService
        self.supportedAssetsRemoteService = supportedAssetsRemoteService
        self.sharedContainer = sharedContainer
        self.analyticsRecorder = analyticsRecorder
        self.customerSupportChatService = customerSupportChatService
        self.crashlyticsRecorder = crashlyticsRecorder
        self.openBanking = openBanking
        self.coincore = coincore
        self.erc20CryptoAssetService = erc20CryptoAssetService
        self.walletService = walletService
        self.forgetWalletService = forgetWalletService
        self.walletPayloadService = walletPayloadService
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
        self.walletRepoPersistence = walletRepoPersistence
        self.secondPasswordPrompter = secondPasswordPrompter
        self.cardService = cardService
        self.externalAppOpener = externalAppOpener
    }
}
