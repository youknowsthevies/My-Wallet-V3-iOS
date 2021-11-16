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

    /// Enable new account SwiftUI picker.
    case newAccountPicker

    /// Enable new Onboarding Tour on the Welcome Flow
    case newOnboardingTour

    /// Enable unified sign in (account upgrade)
    case unifiedSignIn

    /// Enable polling for email login
    case pollingForEmailLogin

    /// New Create Wallet Screen
    case newCreateWalletScreen

    /// Enables native wallet payload instead of JS
    case nativeWalletPayload

    /// OpenBanking
    case openBanking

    /// Enables the new Limits UI in Transaction Flow
    case newTxFlowLimitsUIEnabled

    /// Enables the feature for alpha release overriding internal config.
    var isAlphaReady: Bool {
        switch self {
        case .newAccountPicker,
             .newOnboardingTour,
             .newTxFlowLimitsUIEnabled,
             .openBanking,
             .pollingForEmailLogin,
             .newCreateWalletScreen:
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
        case .newAccountPicker:
            return "New SwiftUI Account Picker"
        case .newOnboardingTour:
            return "New Onboarding Tour"
        case .unifiedSignIn:
            return "Unified Sign In"
        case .pollingForEmailLogin:
            return "Polling (Email Login)"
        case .newCreateWalletScreen:
            return "New Create Wallet Screen"
        case .nativeWalletPayload:
            return "Native Wallet Payload"
        case .openBanking:
            return "Open Banking"
        case .newTxFlowLimitsUIEnabled:
            return "New Limits UI"
        }
    }
}
