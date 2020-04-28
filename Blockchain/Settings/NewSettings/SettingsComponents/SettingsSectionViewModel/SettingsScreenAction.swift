//
//  SettingsScreenAction.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/16/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

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
    case showRemoveCardScreen(CardData)
    case showAddCardScreen
    case none
}
