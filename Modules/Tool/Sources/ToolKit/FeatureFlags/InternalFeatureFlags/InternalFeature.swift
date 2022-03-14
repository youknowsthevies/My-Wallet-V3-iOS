// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Defines an internal feature as part of a FeatureFlag
public enum InternalFeature: String, CaseIterable {

    /// Enabled console logging of network requests for debug builds
    case requestConsoleLogging

    /// Disable SSL pinning for seeing network request
    case disableSSLPinning

    /// Disable the guid login at welcome screen, useful for demo purposes
    /// - Note: Old manual guid login screen is used only for internal builds
    case disableGUIDLogin

    /// Enable unified sign in (account upgrade)
    case unifiedSignIn

    /// Enables native wallet payload instead of JS
    case nativeWalletPayload

    /// Enabled native wallet creation instead of JS
    case nativeWalletCreation

    /// Enables native bitcion transaction
    case nativeBitcoinTransaction

    /// Enables Apple Pay
    case applePay

    /// Enables Redesigned CoinView
    case redesignCoinView

    /// Enables Card Issuing
    case cardIssuing

    /// Enables Blockchain Domains
    case blockchainDomains

    /// Enables the feature for alpha release overriding internal config.
    var isAlphaReady: Bool {
        switch self {
        case .disableGUIDLogin,
             .requestConsoleLogging,
             .disableSSLPinning,
             .unifiedSignIn,
             .nativeWalletPayload,
             .nativeBitcoinTransaction,
             .applePay,
             .nativeWalletCreation,
             .redesignCoinView,
             .blockchainDomains,
             .cardIssuing:
            return false
        }
    }
}

extension InternalFeature {

    internal var defaultsKey: String {
        "internal-flag-\(rawValue)-key"
    }

    /// The title displayed at the Debug menu.
    public var displayTitle: String {
        switch self {
        case .requestConsoleLogging:
            return "Enable Network Request Console Logs"
        case .disableSSLPinning:
            return "Disable SSL Pinning (Requires Restart)"
        case .disableGUIDLogin:
            return "Disable manual (guid) login option"
        case .unifiedSignIn:
            return "Unified Sign In"
        case .nativeWalletPayload:
            return "Native Wallet Payload"
        case .nativeBitcoinTransaction:
            return "Native Bitcoin Transaction"
        case .applePay:
            return "Apple Pay"
        case .nativeWalletCreation:
            return "Native Wallet Creation"
        case .redesignCoinView:
            return "Redesign: CoinView"
        case .blockchainDomains:
            return "Blockchain Domains"
        case .cardIssuing:
            return "Card Issuing"
        }
    }
}
