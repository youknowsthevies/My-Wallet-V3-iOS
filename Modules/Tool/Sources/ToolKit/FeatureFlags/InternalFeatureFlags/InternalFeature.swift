// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Defines an internal feature as part of a FeatureFlag
public enum InternalFeature: String, CaseIterable {

    /// Enable secure channel
    case secureChannel

    /// Enabled console logging of network requests for debug builds
    case requestConsoleLogging

    /// Uses the Transactions Flow implementation of Buy when enabled
    case useTransactionsFlowToBuyCrypto

    /// Enable interest withdraw and deposit
    case interestWithdrawAndDeposit

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

    /// Enables native wallet payload instead of JS
    case nativeWalletPayload

    /// OpenBanking
    case openBanking

    /// Enables the feature for alpha release overriding internal config.
    var isAlphaReady: Bool {
        switch self {
        case .useTransactionsFlowToBuyCrypto,
             .newAccountPicker,
             .newOnboardingTour,
             .openBanking,
             .pollingForEmailLogin:
            return true
        case .disableGUIDLogin,
             .interestWithdrawAndDeposit,
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
        case .interestWithdrawAndDeposit:
            return "Rewards - Deposit and Withdraw"
        case .secureChannel:
            return "Secure Channel"
        case .requestConsoleLogging:
            return "Enable Network Request Console Logs"
        case .useTransactionsFlowToBuyCrypto:
            return "Buy: Uses Transactions Flow to Buy Crypto"
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
        case .nativeWalletPayload:
            return "Native Wallet Payload"
        case .openBanking:
            return "Open Banking"
        }
    }
}
