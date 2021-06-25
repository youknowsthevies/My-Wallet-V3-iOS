// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import PlatformKit

extension AnalyticsEvents.New {
    public enum Withdraw: AnalyticsEvent {

        public var type: AnalyticsEventType {
            .new
        }

        case withdrawViewed
    }
}
