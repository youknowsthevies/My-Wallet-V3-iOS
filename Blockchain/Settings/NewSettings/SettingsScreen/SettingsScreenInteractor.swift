// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit
import RxSwift
import SettingsKit

final class SettingsScreenInteractor {
    
    // MARK: - Interactors
    
    let emailVerificationBadgeInteractor: EmailVerificationBadgeInteractor
    let mobileVerificationBadgeInteractor: MobileVerificationBadgeInteractor
    let twoFactorVerificationBadgeInteractor: TwoFactorVerificationBadgeInteractor
    let preferredCurrencyBadgeInteractor: PreferredCurrencyBadgeInteractor
    let cardSectionInteractor: CardSettingsSectionInteractor
    let bankSectionInteractor: BanksSettingsSectionInteractor

    // MARK: - Services

    /// TODO: All interactors should be created inside this class,
    /// and services should be injected into them through the main class.
    /// The presenter should not contain any interaction logic
    
    let settingsService: SettingsServiceAPI
    let smsTwoFactorService: SMSTwoFactorSettingsServiceAPI
    let emailNotificationsService: EmailNotificationSettingsServiceAPI
    
    let pitConnnectionProviding: PITConnectionStatusProviding
    let balanceSharingService: BalanceSharingSettingsServiceAPI
    let tiersProviding: TierLimitsProviding
    let settingsAuthenticating: AppSettingsAuthenticating
    let biometryProviding: BiometryProviding
    let credentialsStore: CredentialsStoreAPI
    let appSettings: BlockchainSettings.App
    let featureConfigurator: FeatureFetchingConfiguring
    let recoveryPhraseStatusProviding: RecoveryPhraseStatusProviding
    let swipeToReceiveConfiguration: AppFeatureConfiguration

    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()
    
    init(repository: BlockchainDataRepository = BlockchainDataRepository.shared,
         credentialsStore: CredentialsStoreAPI = resolve(),
         featureConfigurator: FeatureFetchingConfiguring = resolve(),
         settingsService: SettingsServiceAPI = resolve(),
         smsTwoFactorService: SMSTwoFactorSettingsServiceAPI = resolve(),
         emailNotificationService: EmailNotificationSettingsServiceAPI = resolve(),
         appSettings: BlockchainSettings.App = resolve(),
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = resolve(),
         pitConnectionAPI: PITConnectionStatusProviding = PITConnectionStatusProvider(),
         settingsAuthenticating: AppSettingsAuthenticating = resolve(),
         tiersService: KYCTiersServiceAPI = resolve(),
         wallet: Wallet = WalletManager.shared.wallet,
         balanceProviding: BalanceProviding = DataProvider.default.balance,
         balanceChangeProviding: BalanceChangeProviding = DataProvider.default.balanceChange,
         paymentMethodTypesService: PaymentMethodTypesServiceAPI) {
        self.smsTwoFactorService = smsTwoFactorService
        self.appSettings = appSettings
        self.settingsService = settingsService
        self.featureConfigurator = featureConfigurator
        self.emailNotificationsService = emailNotificationService
        
        self.balanceSharingService = PortfolioSyncingService(
            balanceProviding: balanceProviding,
            balanceChangeProviding: balanceChangeProviding,
            fiatCurrencyProviding: fiatCurrencyService
        )
        
        tiersProviding = TierLimitsProvider(tiersService: tiersService)

        cardSectionInteractor = CardSettingsSectionInteractor(
            paymentMethodTypesService: paymentMethodTypesService,
            tierLimitsProvider: tiersProviding
        )
        
        bankSectionInteractor = BanksSettingsSectionInteractor(
            paymentMethodTypesService: paymentMethodTypesService,
            tierLimitsProvider: tiersProviding
        )
        
        emailVerificationBadgeInteractor = EmailVerificationBadgeInteractor(
            service: settingsService
        )
        mobileVerificationBadgeInteractor = MobileVerificationBadgeInteractor(
            service: settingsService
        )
        twoFactorVerificationBadgeInteractor = TwoFactorVerificationBadgeInteractor(
            service: settingsService
        )
        preferredCurrencyBadgeInteractor = PreferredCurrencyBadgeInteractor(
            settingsService: settingsService,
            fiatCurrencyService: fiatCurrencyService
        )
        
        swipeToReceiveConfiguration = featureConfigurator.configuration(for: .swipeToReceive)
        self.biometryProviding = BiometryProvider(settings: settingsAuthenticating, featureConfigurator: featureConfigurator)
        self.settingsAuthenticating = settingsAuthenticating
        self.pitConnnectionProviding = pitConnectionAPI
        self.recoveryPhraseStatusProviding = RecoveryPhraseStatusProvider(wallet: wallet)
        self.credentialsStore = credentialsStore
    }
    
    func refresh() {
        recoveryPhraseStatusProviding.fetchTriggerRelay.accept(())
        pitConnnectionProviding.fetchTriggerRelay.accept(())
        tiersProviding.fetchTriggerRelay.accept(())
        settingsService.fetch(force: true)
            .subscribe()
            .disposed(by: disposeBag)
    }
}
