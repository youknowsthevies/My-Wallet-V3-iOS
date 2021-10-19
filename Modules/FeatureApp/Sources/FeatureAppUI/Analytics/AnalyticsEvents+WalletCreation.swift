// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

extension AnalyticsEvents.New {
    enum Onboarding: AnalyticsEvent {

        var type: AnalyticsEventType { .nabu }

        case walletSignedUp
    }
}
