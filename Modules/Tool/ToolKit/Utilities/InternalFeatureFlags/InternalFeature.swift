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
    
    /// Enabled console logging of network requests for debug builds
    case requestConsoleLogging
    
    /// Shows Email Verification insted of Simple Buy at Login
    case showEmailVerificationAtLogin
    
    internal var defaultsKey: String {
        "internal-flag-\(rawValue)-key"
    }
}
