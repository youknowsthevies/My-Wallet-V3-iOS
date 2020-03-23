//
//  SettingsScreenInteractor.swift
//  Blockchain
//
//  Created by AlexM on 12/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit

final class SettingsScreenInteractor {
    
    // MARK: - Interactors
    
    let emailVerificationBadgeInteractor: EmailVerificationBadgeInteractor
    let mobileVerificationBadgeInteractor: MobileVerificationBadgeInteractor
    let twoFactorVerificationBadgeInteractor: TwoFactorVerificationBadgeInteractor
    let preferredCurrencyBadgeInteractor: PreferredCurrencyBadgeInteractor
    
    // MARK: - Services

    /// TODO: All interactors should be created inside this class,
    /// and services should be injected into them through the main class.
    /// The presenter should not contain any interaction logic
    
    let settingsService: SettingsServiceAPI
    let smsTwoFactorService: SMSTwoFactorSettingsServiceAPI
    let emailNotificationsService: SettingsServiceAPI & EmailNotificationSettingsServiceAPI
    
    let pitConnnectionProviding: PITConnectionStatusProviding
    let tiersProviding: TierLimitsProviding
    let settingsAuthenticating: AppSettingsAuthenticating
    let biometryProviding: BiometryProviding
    let appSettings: BlockchainSettings.App
    
    let recoveryPhraseStatusProviding: RecoveryPhraseStatusProviding
    let pitLinkingConfiguration: AppFeatureConfiguration
    
    init(repository: BlockchainDataRepository = BlockchainDataRepository.shared,
         featureConfigurator: FeatureConfiguring = AppFeatureConfigurator.shared,
         settingsService: SettingsServiceAPI = UserInformationServiceProvider.default.settings,
         smsTwoFactorService: SMSTwoFactorSettingsServiceAPI = UserInformationServiceProvider.default.settings,
         emailNotificationSerivce: EmailNotificationSettingsServiceAPI = UserInformationServiceProvider.default.settings,
         appSettings: BlockchainSettings.App = BlockchainSettings.App.shared,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = UserInformationServiceProvider.default.settings,
         pitConnectionAPI: PITConnectionStatusProviding = PITConnectionStatusProvider(),
         settingsAuthenticating: AppSettingsAuthenticating = BlockchainSettings.App.shared,
         wallet: Wallet = WalletManager.shared.wallet) {
        self.smsTwoFactorService = smsTwoFactorService
        self.appSettings = appSettings
        self.settingsService = settingsService
        self.emailNotificationsService = emailNotificationSerivce
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
        tiersProviding = TierLimitsProvider(repository: repository)
        self.biometryProviding = BiometryProvider(settings: settingsAuthenticating, featureConfigurator: featureConfigurator)
        self.settingsAuthenticating = settingsAuthenticating
        self.pitConnnectionProviding = pitConnectionAPI
        self.recoveryPhraseStatusProviding = RecoveryPhraseStatusProvider(wallet: wallet)
    }
    
    func refresh() {
        recoveryPhraseStatusProviding.fetchTriggerRelay.accept(())
        pitConnnectionProviding.fetchTriggerRelay.accept(())
        tiersProviding.fetchTriggerRelay.accept(())
        settingsService.refresh()
    }
}
