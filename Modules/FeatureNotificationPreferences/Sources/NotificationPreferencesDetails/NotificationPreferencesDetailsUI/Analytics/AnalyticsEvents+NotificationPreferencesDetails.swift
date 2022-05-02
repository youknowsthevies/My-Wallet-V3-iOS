//
//  File.swift
//  
//
//  Created by Augustin Udrea on 02/05/2022.
//

import Foundation
import AnalyticsKit

extension AnalyticsEvents.New {
    enum NotificationPreferenceDetailsEvents: AnalyticsEvent {

        var type: AnalyticsEventType { .nabu }

        case priceAlertsSetUp(email: SwitchValue,
                              in_app: SwitchValue,
                              push: SwitchValue)
        
        case securityAlertsSetUp(email: SwitchValue,
                                 in_app: SwitchValue,
                                 push: SwitchValue,
                                 sms: SwitchValue)

        case walletActivitySetUp(email: SwitchValue,
                                 in_app: SwitchValue,
                                 push: SwitchValue,
                                 sms: SwitchValue)

        case newsSetUp(email: SwitchValue,
                       in_app: SwitchValue,
                       push: SwitchValue,
                       sms: SwitchValue)

        enum Origin: String, StringRawRepresentable {
            case notificationPrefences = "NOTIFICATION_PREFERENCES"
        }

        enum SwitchValue: String, StringRawRepresentable {
            case enable = "Enable"
            case disable = "Disable"

            init(_ value: Bool) {
                self = value ? .enable : .disable
            }
        }
    }
}

extension AnalyticsEventRecorderAPI {
    func record(event: AnalyticsEvents.New.NotificationPreferenceDetailsEvents) {
        record(event: event as AnalyticsEvent)
    }

    func record(events: [AnalyticsEvents.New.NotificationPreferenceDetailsEvents]) {
        record(events: events as [AnalyticsEvent])
    }
}
