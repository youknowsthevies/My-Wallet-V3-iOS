// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation

extension AnalyticsEvents.New {
    enum Deeplinking: AnalyticsEvent {
        public var type: AnalyticsEventType { .nabu }

        case walletReferralProgramClicked(source: String = "deeplink")
    }
}
