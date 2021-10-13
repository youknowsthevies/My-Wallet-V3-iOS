// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit

extension InterestAccountIneligibilityReason {

    private typealias LocalizationId = LocalizationConstants.Interest.Screen.Overview.Action

    var displayString: String {
        switch self {
        case .eligible:
            return LocalizationId.view
        case .tierTooLow:
            return LocalizationId.tierTooLow
        case .unsupportedRegion:
            return LocalizationId.notAvailable
        case .invalidAddress,
             .other:
            return LocalizationId.unavailable
        }
    }
}
