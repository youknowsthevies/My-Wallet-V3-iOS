//
//  SettingsCellType+Action.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/20/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import BuySellUIKit

extension SettingsSectionType.CellType {
    var action: SettingsScreenAction {
        switch self {
        case .badge(let type, let presenter):
            guard !presenter.isLoading else { return .none }
            switch type {
            case .currencyPreference:
                return .showCurrencySelectionScreen
            case .emailVerification:
                return .showUpdateEmailScreen
            case .limits:
                return .launchKYC
            case .mobileVerification:
                return .showUpdateMobileScreen
            case .pitConnection:
                return .launchPIT
            case .recoveryPhrase:
                return .showBackupScreen
            }
        case .cards(let type):
            switch type {
            case .linkedCard(let presenter):
                return .showRemoveCardScreen(presenter.cardData)
            case .addCard(let presenter):
                guard !presenter.isLoading else { return .none }
                return presenter.action
            }
        case .clipboard(let type):
            switch type {
            case .walletID:
                return .promptGuidCopy
            }
        case .plain(let type):
            switch type {
            case .changePassword:
                return .launchChangePassword
            case .changePIN:
                return .showChangePinScreen
            case .loginToWebWallet:
                return .launchWebLogin
            case .rateUs:
                return .showAppStore
            case .termsOfService:
                return .showURL(URL(string: Constants.Url.termsOfService)!)
            case .privacyPolicy,
                 .cookiesPolicy:
                return .showURL(URL(string: Constants.Url.privacyPolicy)!)
            }
        case .switch:
            return .none
        }
    }
}
