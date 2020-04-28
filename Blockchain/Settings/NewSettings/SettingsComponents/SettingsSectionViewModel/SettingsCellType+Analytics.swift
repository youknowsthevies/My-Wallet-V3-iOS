//
//  SettingsCellType+Analytics.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/15/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit

extension SettingsSectionType.CellType {
    var analyticsEvent: AnalyticsEvents.Settings? {
        switch self {
        case .badge(let type, _):
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
}
