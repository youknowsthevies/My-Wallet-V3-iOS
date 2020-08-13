//
//  SettingsScreenInteractor.swift
//  Blockchain
//
//  Created by AlexM on 12/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxSwift

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
    let cardsService: CardServiceProviderAPI
    let simpleBuyService: ServiceProviderAPI
    let smsTwoFactorService: SMSTwoFactorSettingsServiceAPI
    let emailNotificationsService: EmailNotificationSettingsServiceAPI
    
    let pitConnnectionProviding: PITConnectionStatusProviding
    let balanceSharingService: BalanceSharingSettingsServiceAPI
    let tiersProviding: TierLimitsProviding
    let settingsAuthenticating: AppSettingsAuthenticating
    let biometryProviding: BiometryProviding
    let credentialsStore: CredentialsStoreAPI
    let appSettings: BlockchainSettings.App
    let featureConfigurator: FeatureFetching & FeatureConfiguring
    let recoveryPhraseStatusProviding: RecoveryPhraseStatusProviding
    let pitLinkingConfiguration: AppFeatureConfiguration
    let simpleBuyCardsConfiguration: AppFeatureConfiguration
    let swipeToReceiveConfiguration: AppFeatureConfiguration

    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()
    
    init(repository: BlockchainDataRepository = BlockchainDataRepository.shared,
         credentialsStore: CredentialsStoreAPI = resolve(),
         featureConfigurator: FeatureFetching & FeatureConfiguring = AppFeatureConfigurator.shared,
         settingsService: SettingsServiceAPI = UserInformationServiceProvider.default.settings,
         smsTwoFactorService: SMSTwoFactorSettingsServiceAPI = UserInformationServiceProvider.default.settings,
         emailNotificationService: EmailNotificationSettingsServiceAPI = UserInformationServiceProvider.default.settings,
         appSettings: BlockchainSettings.App = resolve(),
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings,
         pitConnectionAPI: PITConnectionStatusProviding = PITConnectionStatusProvider(),
         settingsAuthenticating: AppSettingsAuthenticating = resolve(),
         tiersService: KYCTiersServiceAPI = KYCServiceProvider.default.tiers,
         wallet: Wallet = WalletManager.shared.wallet,
         cardsService: CardServiceProviderAPI = CardServiceProvider.default,
         simpleBuyService: ServiceProviderAPI = DataProvider.default.buySell,
         balanceProviding: BalanceProviding = DataProvider.default.balance,
         balanceChangeProviding: BalanceChangeProviding = DataProvider.default.balanceChange) {
        self.simpleBuyService = simpleBuyService
        self.cardsService = cardsService
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
            featureFetcher: featureConfigurator,
            paymentMethodTypesService: simpleBuyService.paymentMethodTypes,
            tierLimitsProvider: tiersProviding
        )
        
        bankSectionInteractor = BanksSettingsSectionInteractor(
            beneficiariesService: simpleBuyService.beneficiaries,
            featureFetcher: featureConfigurator,
            paymentMethodTypesService: simpleBuyService.paymentMethodTypes,
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
        
        pitLinkingConfiguration = featureConfigurator.configuration(for: .exchangeLinking)
        simpleBuyCardsConfiguration = featureConfigurator.configuration(for: .simpleBuyCardsEnabled)
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
