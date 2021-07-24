// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Defines an internal feature as part of a FeatureFlag
public enum InternalFeature: String, CaseIterable {

    /// Enable secure channel
    case secureChannel

    /// Enable the new Pin/OnBoarding which uses ComposableArchitecture
    case newOnboarding

    /// Enabled console logging of network requests for debug builds
    case requestConsoleLogging

    /// Uses the Transactions Flow implementation of Buy when enabled
    case useTransactionsFlowToBuyCrypto

    /// Disable the guid login at welcome screen, useful for demo purposes
    /// - Note: Old manual guid login screen is used only for internal builds
    case disableGUIDLogin
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
        case .newOnboarding:
            return "Disable New Pin/Onboarding"
        case .requestConsoleLogging:
            return "Enable Network Request Console Logs"
        case .useTransactionsFlowToBuyCrypto:
            return "Uses Transactions Flow to Buy Crypto"
        case .disableGUIDLogin:
            return "Disable manual (guid) login option"
        }
    }
}
