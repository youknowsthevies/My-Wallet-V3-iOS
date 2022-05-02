//
//  File.swift
//  
//
//  Created by Augustin Udrea on 02/05/2022.
//

import Foundation
import AnalyticsKit

extension AnalyticsEvents.New {
    enum NotificationPreferencesEvents: AnalyticsEvent {

        var type: AnalyticsEventType { .nabu }

        case notificationClicked
        case notificationPreferencesClicked(optionSelection: String)
        case notificationPreferencesViewed(option_viewed: String)
        case notificationViewed
        case notificationsClosed
        case statusChangeError(origin: Origin)

        enum Origin: String, StringRawRepresentable {
            case notificationPrefences = "NOTIFICATION_PREFERENCES"
        }
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
