// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Defines an internal feature as part of a FeatureFlag
public enum InternalFeature: String, CaseIterable {

    /// Enable secure channel
    case secureChannel

    /// Enabled console logging of network requests for debug builds
    case requestConsoleLogging

    /// Disable the guid login at welcome screen, useful for demo purposes
    /// - Note: Old manual guid login screen is used only for internal builds
    case disableGUIDLogin

    /// Enable new Onboarding Tour on the Welcome Flow
    case newOnboardingTour

    /// Enable unified sign in (account upgrade)
    case unifiedSignIn

    /// Enables native wallet payload instead of JS
    case nativeWalletPayload

    /// OpenBanking
    case openBanking

    /// Enables New Card Acquirers (Stripe and Checkout)
    case newCardAcquirers

    /// Redesign
    case redesign

    /// Enables the feature for alpha release overriding internal config.
    var isAlphaReady: Bool {
        switch self {
        case .newOnboardingTour,
             .openBanking,
             .newCardAcquirers,
             .redesign:
            return true
        case .disableGUIDLogin,
             .requestConsoleLogging,
             .secureChannel,
             .unifiedSignIn,
             .nativeWalletPayload:
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
        case .secureChannel:
            return "Secure Channel"
        case .requestConsoleLogging:
            return "Enable Network Request Console Logs"
        case .disableGUIDLogin:
            return "Disable manual (guid) login option"
        case .newOnboardingTour:
            return "New Onboarding Tour"
        case .unifiedSignIn:
            return "Unified Sign In"
        case .nativeWalletPayload:
            return "Native Wallet Payload"
        case .openBanking:
            return "Open Banking"
        case .newCardAcquirers:
            return "New Card Acquirers (Stripe, Checkout)"
        case .redesign:
            return "Redesign"
        }
    }
}
