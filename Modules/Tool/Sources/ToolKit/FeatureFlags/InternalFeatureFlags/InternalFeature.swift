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

    /// Enable split dashboard screen.
    case splitDashboard

    /// Enable new account SwiftUI picker.
    case newAccountPicker

    /// Load All ERC20 Tokens.
    case loadAllERC20Tokens

    /// Enable new Onboarding Tour on the Welcome Flow
    case newOnboardingTour

    /// Enable unified sign in (account upgrade)
    case unifiedSignIn

    /// Enables native wallet payload instead of JS
    case nativeWalletPayload

    /// Enables the feature for alpha release overriding internal config.
    var isAlphaReady: Bool {
        switch self {
        case .disableGUIDLogin,
             .interestWithdrawAndDeposit,
             .newAccountPicker,
             .newOnboardingTour,
             .requestConsoleLogging,
             .secureChannel,
             .useTransactionsFlowToBuyCrypto,
             .unifiedSignIn,
             .nativeWalletPayload:
            return false
        case .splitDashboard,
             .loadAllERC20Tokens:
            return true
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
        case .splitDashboard:
            return "Split Dashboard Screen"
        case .newAccountPicker:
            return "New SwiftUI Account Picker"
        case .loadAllERC20Tokens:
            return "Load All ERC20 Tokens"
        case .newOnboardingTour:
            return "New Onboarding Tour"
        case .unifiedSignIn:
            return "Unified Sign In"
        case .nativeWalletPayload:
            return "Native Wallet Payload"
        }
    }
}
