//
//  SettingsScreenPresenter.swift
//  Blockchain
//
//  Created by AlexM on 12/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxRelay
import RxCocoa
import RxSwift
import ToolKit

/// This enum aggregates possible action types that can be done in the dashboard
enum SettingsScreenAction {
    case launchChangePassword
    case launchWebLogin
    case promptGuidCopy
    case launchKYC
    case launchPIT
    case showAppStore
    case showBackupScreen
    case showChangePinScreen
    case showCurrencySelectionScreen
    case showUpdateEmailScreen
    case showUpdateMobileScreen
    case showURL(URL)
    case none
}

final class SettingsScreenPresenter {
    
    // MARK: Private Static Properties
    
    private static let termsOfServiceURL = URL(string: Constants.Url.termsOfService)!
    private static let privacyURL = URL(string: Constants.Url.privacyPolicy)!
    
    // MARK: - Navigation Properties
    
    let trailingButton: Screen.Style.TrailingButton = .none
    
    var leadingButton: Screen.Style.LeadingButton {
        if #available(iOS 13.0, *) {
            return .none
        } else {
            return .close
        }
    }
    
    var barStyle: Screen.Style.Bar {
        return .lightContent(ignoresStatusBar: false, background: .navigationBarBackground)
    }
    
    // MARK: - Types
    
    enum Section: Hashable {
        case profile
        case preferences
        case connect
        case security
        case cards
        case about
        
        enum CellType: Hashable {
            case badge(BadgeCellType)
            case `switch`(SwitchCellType)
            case clipboard(ClipboardCellType)
            case cards(CardsCellType)
            case plain(PlainCellType)
            
            enum BadgeCellType {
                case limits
                case emailVerification
                case mobileVerification
                case currencyPreference
                case pitConnection
                case recoveryPhrase
            }
            
            enum SwitchCellType {
                case sms2FA
                case emailNotifications
                case bioAuthentication
                case swipeToReceive
            }
            
            enum ClipboardCellType: String {
                case walletID
            }
            
            enum CardsCellType {
                case linkedCard
                case addCard
            }
            
            enum PlainCellType: String {
                case loginToWebWallet
                case changePassword
                case changePIN
                case rateUs
                case termsOfService
                case privacyPolicy
                case cookiesPolicy
            }
        }
    }
    
    // MARK: - Public Properties
    
    var sectionArrangement: [Section] {
        var sections: [Section] = [.profile,
                                   .preferences,
                                   .security,
                                   .about]
        if interactor.pitLinkingConfiguration.isEnabled {
            sections.insert(.connect, at: 2)
        }
        
        return sections
    }
    
    var sectionCount: Int {
        return sectionArrangement.count
    }
    
    // MARK: - Cell Presenters
    
    let linkedCardPresenter: LinkedCardCellPresenter
    let addCardCellPresenter: AddCardCellPresenter
    let mobileCellPresenter: MobileVerificationCellPresenter
    let emailCellPresenter: EmailVerificationCellPresenter
    let preferredCurrencyCellPresenter: PreferredCurrencyCellPresenter
    let smsTwoFactorSwitchCellPresenter: SMSTwoFactorSwitchCellPresenter
    let emailNotificationsCellPresenter: EmailNotificationsSwitchCellPresenter
    let bioAuthenticationCellPresenter: BioAuthenticationSwitchCellPresenter
    let swipeReceiveCellPresenter: SwipeReceiveSwitchCellPresenter

    let pitCellPresenter: PITConnectionCellPresenter
    let recoveryCellPresenter: RecoveryStatusCellPresenter
    let limitsCellPresenter: TierLimitsCellPresenter
    
    // MARK: - Public
    
    let selectionRelay = PublishRelay<Section.CellType>()

    // MARK: Private Properties
    
    private unowned let router: SettingsRouterAPI
    private let interactor: SettingsScreenInteractor
    private let disposeBag = DisposeBag()
    
    init(interactor: SettingsScreenInteractor = SettingsScreenInteractor(),
         router: SettingsRouterAPI) {
        self.router = router
        self.interactor = interactor
        linkedCardPresenter = LinkedCardCellPresenter()
        addCardCellPresenter = AddCardCellPresenter()
        emailNotificationsCellPresenter = EmailNotificationsSwitchCellPresenter(service: interactor.emailNotificationsService)
        emailCellPresenter = EmailVerificationCellPresenter(
            interactor: interactor.emailVerificationBadgeInteractor
        )
        mobileCellPresenter = MobileVerificationCellPresenter(
            interactor: interactor.mobileVerificationBadgeInteractor
        )
        preferredCurrencyCellPresenter = PreferredCurrencyCellPresenter(
            interactor: interactor.preferredCurrencyBadgeInteractor
        )
        
        /// TODO: Provide interactor to the presenter as services
        /// should not be accessed from the presenter
        
        limitsCellPresenter = TierLimitsCellPresenter(
            tiersProviding: interactor.tiersProviding
        )
        pitCellPresenter = PITConnectionCellPresenter(
            pitConnectionProvider: interactor.pitConnnectionProviding
        )
        recoveryCellPresenter = RecoveryStatusCellPresenter(
            recoveryStatusProviding: interactor.recoveryPhraseStatusProviding
        )
        bioAuthenticationCellPresenter = BioAuthenticationSwitchCellPresenter(
            biometryProviding: interactor.biometryProviding,
            appSettingsAuthenticating: interactor.settingsAuthenticating
        )
        swipeReceiveCellPresenter = SwipeReceiveSwitchCellPresenter(
            appSettings: interactor.appSettings
        )
        smsTwoFactorSwitchCellPresenter = SMSTwoFactorSwitchCellPresenter(service: interactor.smsTwoFactorService)
        
        selectionRelay
            .map { $0.action }
            .bind(to: router.actionRelay)
            .disposed(by: disposeBag)
    }
    
    /// Should be called each time the `Settings` screen comes into view
    func refresh() {
        interactor.refresh()
    }
    
    /// MARK: - Exposed
    
    func navigationBarLeadingButtonTapped() {
        router.previousRelay.accept(())
    }
}

extension SettingsScreenPresenter.Section.CellType {
    
    var analyticsEvent: AnalyticsEvents.Settings? {
        switch self {
        case .badge(let type):
            switch type {
            case .currencyPreference,
                 .limits,
                 .pitConnection:
                return nil
            case .emailVerification:
                return .settingsEmailClicked
            case .mobileVerification:
                return .settingsPhoneClicked
            case .recoveryPhrase:
                return .settingsRecoveryPhraseClick
            }
        case .switch:
            return nil
        case .clipboard(let type):
            switch type {
            case .walletID:
                return .settingsWalletIdCopyClick
            }
        case .cards(let type):
        // TODO: IOS-3100 - Analytics
            // TODO: Analytics
            return nil
        case .plain(let type):
            switch type {
            case .loginToWebWallet:
                return .settingsWebWalletLoginClick
            case .changePassword:
                return .settingsPasswordClick
            case .changePIN:
                return .settingsChangePinClick
            case .termsOfService,
                 .privacyPolicy,
                 .cookiesPolicy,
                 .rateUs:
                return nil
            }
        }
    }
    
    var action: SettingsScreenAction {
        switch self {
        case .badge(let type):
            switch type {
            case .currencyPreference:
                return .showCurrencySelectionScreen
            case .limits:
                return .launchKYC
            case .emailVerification:
                return .showUpdateEmailScreen
            case .mobileVerification:
                return .showUpdateMobileScreen
            case .pitConnection:
                return .launchPIT
            case .recoveryPhrase:
                return .showBackupScreen
            }
        case .cards(let type):
            return .none
        case .switch:
            return .none
        case .clipboard(let type):
            switch type {
            case .walletID:
                return .promptGuidCopy
            }
        case .plain(let type):
            switch type {
            case .rateUs:
                return .showAppStore
            case .loginToWebWallet:
                return .launchWebLogin
            case .changePassword:
                return .launchChangePassword
            case .changePIN:
                return .showChangePinScreen
            case .termsOfService:
                return .showURL(SettingsScreenPresenter.termsOfServiceURL)
            case .privacyPolicy,
                 .cookiesPolicy:
                return .showURL(SettingsScreenPresenter.privacyURL)
            }
        }
    }
}

extension SettingsScreenPresenter.Section {
    // TODO: Async Arrangement - Fetch Linked Cards
    // TICKET: IOS-3120
    var cellArrangement: [CellType] {
        switch self {
        case .profile:
            return [.badge(.limits),
                    .clipboard(.walletID),
                    .badge(.emailVerification),
                    .badge(.mobileVerification),
                    .plain(.loginToWebWallet)]
        case .preferences:
            return [.switch(.emailNotifications),
                    .badge(.currencyPreference)]
        case .connect:
            return [.badge(.pitConnection)]
        case .cards:
            return [.cards(.linkedCard),
                    .cards(.addCard)]
        case .security:
            var arrangement: [CellType] = [.switch(.sms2FA),
                                           .plain(.changePassword),
                                           .badge(.recoveryPhrase),
                                           .plain(.changePIN),
                                           .switch(.bioAuthentication)]
            
            if AppFeatureConfigurator.shared.configuration(for: .swipeToReceive).isEnabled {
                arrangement.append(.switch(.swipeToReceive))
            }
            
            return arrangement
        case .about:
            return [.plain(.rateUs),
                    .plain(.termsOfService),
                    .plain(.privacyPolicy),
                    .plain(.cookiesPolicy)]
        }
    }
    
    var sectionCellCount: Int {
        return cellArrangement.count
    }
    
    var sectionTitle: String {
        switch self {
        case .profile:
            return LocalizationConstants.Settings.Section.profile
        case .preferences:
            return LocalizationConstants.Settings.Section.preferences
        case .connect:
            return LocalizationConstants.Settings.Section.walletConnect
        case .security:
            return LocalizationConstants.Settings.Section.security
        case .cards:
            return LocalizationConstants.Settings.Section.linkedCards
        case .about:
            return LocalizationConstants.Settings.Section.about
        }
    }
}

extension SettingsScreenPresenter.Section.CellType.ClipboardCellType {
    var title: String {
        switch self {
        case .walletID:
            return LocalizationConstants.Settings.walletID
        }
    }
    
    var accessibilityID: String {
        return self.rawValue
    }
}

extension SettingsScreenPresenter.Section.CellType.PlainCellType {
    var title: String {
        switch self {
        case .rateUs:
            return LocalizationConstants.Settings.rateUs
        case .loginToWebWallet:
            return LocalizationConstants.Settings.loginToWebWallet
        case .changePassword:
            return LocalizationConstants.Settings.changePassword
        case .changePIN:
            return LocalizationConstants.Settings.changePIN
        case .termsOfService:
            return LocalizationConstants.Settings.termsOfService
        case .privacyPolicy:
            return LocalizationConstants.Settings.privacyPolicy
        case .cookiesPolicy:
            return LocalizationConstants.Settings.cookiesPolicy
        }
    }
    
    var accessibilityID: String {
        return self.rawValue
    }
}
