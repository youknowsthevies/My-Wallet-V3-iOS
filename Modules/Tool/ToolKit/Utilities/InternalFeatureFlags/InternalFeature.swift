// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Defines an internal feature as part of a FeatureFlag
public enum InternalFeature: String, CaseIterable {

    /// Enable secure channel
    case secureChannel

    /// Enable receiving to trading account
    case tradingAccountReceive

    /// Enables deposit and withdraw for US users
    case withdrawAndDepositACH

    /// Enable the new Pin/OnBoarding which uses ComposableArchitecture
    case newOnboarding

    /// Enabled console logging of network requests for debug builds
    case requestConsoleLogging

    // MARK: - Email Verification

    /// Shows Email Verification insted of Simple Buy at Login
    case showEmailVerificationAtLogin

    /// Shows Email Verification, if needed, when a user tries to make a purchase
    case showEmailVerificationInBuyFlow
}

extension InternalFeature {

    internal var defaultsKey: String {
        "internal-flag-\(rawValue)-key"
    }
}
