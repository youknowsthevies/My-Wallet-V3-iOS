// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Defines an internal feature as part of a FeatureFlag
public enum InternalFeature: String, CaseIterable {
    
    /// Enable secure channel
    case secureChannel

    /// Enable receiving to trading account
    case tradingAccountReceive
    
    /// Enabled deposit and withdraw for US users
    case withdrawAndDepositACH
    
    internal var defaultsKey: String {
        "internal-flag-\(rawValue)-key"
    }
}
