// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import PlatformKit
import PlatformUIKit
import ToolKit

/// Model definition for an item that is presented in the side menu of the app.
enum SideMenuItem {
    case accountsAndAddresses
    case backup
    case buy
    case sell
    case logout
    case airdrops
    case settings
    case support
    /// Legacy QR code connection flow
    case webLogin
    /// Secure Channel QR code connection flow
    case secureChannel
    case lockbox
    case exchange
    case interest
}

extension SideMenuItem {

    var analyticsEvents: [AnalyticsEvent] {
        switch self {
        case .interest:
            return [AnalyticsEvents.SideMenu.sideNavInterest]
        case .accountsAndAddresses:
            return [AnalyticsEvents.SideMenu.sideNavAccountsAndAddresses]
        case .backup:
            return [AnalyticsEvents.SideMenu.sideNavBackup]
        case .buy:
            return [
                AnalyticsEvents.SideMenu.sideNavSimpleBuy,
                AnalyticsEvents.New.SimpleBuy.buySellClicked(type: .buy, origin: .navigation)
            ]
        case .sell:
            return [
                AnalyticsEvents.SideMenu.sideNavSimpleBuy,
                AnalyticsEvents.New.SimpleBuy.buySellClicked(type: .sell, origin: .navigation)
            ]
        case .logout:
            return [AnalyticsEvents.SideMenu.sideNavLogout]
        case .settings:
            return [AnalyticsEvents.SideMenu.sideNavSettings]
        case .airdrops:
            return [AnalyticsEvents.SideMenu.sideNavAirdropCenter]
        case .support:
            return [AnalyticsEvents.SideMenu.sideNavSupport]
        case .webLogin:
            return [AnalyticsEvents.SideMenu.sideNavWebLogin]
        case .lockbox:
            return [AnalyticsEvents.SideMenu.sideNavLockbox]
        case .exchange:
            return [AnalyticsEvents.SideMenu.sideNavExchange]
        case .secureChannel:
            return [AnalyticsEvents.SideMenu.sideNavSecureChannel]
        }
    }

    var title: String {
        switch self {
        case .interest:
            return LocalizationConstants.SideMenu.earnInterest
        case .accountsAndAddresses:
            return LocalizationConstants.SideMenu.addresses
        case .backup:
            return LocalizationConstants.SideMenu.backupFunds
        case .buy:
            return LocalizationConstants.SideMenu.buyCrypto
        case .sell:
            return LocalizationConstants.SideMenu.sellCrypto
        case .logout:
            return LocalizationConstants.SideMenu.logout
        case .settings:
            return LocalizationConstants.SideMenu.settings
        case .airdrops:
            return LocalizationConstants.SideMenu.airdrops
        case .support:
            return LocalizationConstants.SideMenu.support
        case .webLogin:
            return LocalizationConstants.SideMenu.loginToWebWallet
        case .lockbox:
            return LocalizationConstants.SideMenu.lockbox
        case .exchange:
            return LocalizationConstants.SideMenu.exchange
        case .secureChannel:
            return LocalizationConstants.SideMenu.secureChannel
        }
    }

    private var imageName: String {
        switch self {
        case .interest:
            return "menu_interest"
        case .accountsAndAddresses:
            return "menu-icon-addresses"
        case .backup:
            return "menu-icon-backup"
        case .buy:
            return "menu-icon-buy"
        case .sell:
            return "menu-icon-sell"
        case .logout:
            return "menu-icon-logout"
        case .airdrops:
            return "menu-icon-airdrop"
        case .settings:
            return "menu-icon-settings"
        case .support:
            return "menu-icon-chat"
        case .webLogin:
            return "menu-icon-pair-web-wallet"
        case .lockbox:
            return "menu-icon-lockbox"
        case .exchange:
            return "menu-icon-exchange"
        case .secureChannel:
            return "menu-icon-laptop"
        }
    }

    var image: UIImage {
        UIImage(named: imageName)!
    }

    var isNew: Bool {
        switch self {
        case .accountsAndAddresses,
             .backup,
             .buy,
             .sell,
             .logout,
             .settings,
             .support,
             .airdrops,
             .lockbox,
             .webLogin,
             .interest,
             .secureChannel:
            return false
        case .exchange:
            return true
        }
    }
}
