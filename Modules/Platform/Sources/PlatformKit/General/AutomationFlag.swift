// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum AutomationFlag: String {
    case eraseWallet = "automation_erase_data"
}

extension ProcessInfo {
    /// Return Boolean value for given key.
    ///
    /// If the value for the given key is any string other than `"true"` or
    /// `"false"` (case insensitive), the result is `nil`.
    public func environmentBoolean(for key: AutomationFlag) -> Bool? {
        environmentBoolean(for: key.rawValue)
    }
}
