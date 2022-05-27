// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation

extension AnalyticsEvents.New {
    enum NotificationPreferencesEvents: AnalyticsEvent {
        var type: AnalyticsEventType { .nabu }

        case notificationPreferencesClicked(optionSelection: String)
        case notificationPreferencesViewed(option_viewed: String)
        case notificationViewed
        case notificationsClosed
        case statusChangeError(origin: String)
    }
}

extension AnalyticsEventRecorderAPI {
    func record(event: AnalyticsEvents.New.NotificationPreferencesEvents) {
        record(event: event as AnalyticsEvent)
    }

    func record(events: [AnalyticsEvents.New.NotificationPreferencesEvents]) {
        record(events: events as [AnalyticsEvent])
    }
}
