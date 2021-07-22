// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

extension UserDefaults {
    enum Keys: String {
        case walletIntroLatestLocation
        case firstRun

        // MARK: - PIN Login Flow

        case walletWrongPinAttempts
        case walletLastWrongPinTimestamp
    }
}
