// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation

extension AnalyticsEvents.New {
    enum Navigation: AnalyticsEvent {

        var type: AnalyticsEventType { .new }

        case signedIn
        case signedOut
    }
}
