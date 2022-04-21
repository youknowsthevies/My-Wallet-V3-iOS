//
//  NotificationPreferencesActivityTogglesView+Reducer.swift
//  FeatureBuilder
//
//  Created by Augustin Udrea on 12/04/2022.
//

import ComposableArchitecture
import Foundation
import FeatureNotificationPreferencesDetailsDomain
import FeatureNotificationPreferencesDomain

public let notificationPreferencesDetailsReducer = Reducer<
    NotificationPreferencesDetailsState,
    NotificationPreferencesDetailsAction,
    NotificationPreferencesDetailsEnvironment
> { state, action, environment in
    switch action {
    case .onDissapear:
        let updatedPreferences = [
            UpdatedNotificationPreference(contactMethod: NotificationMethod.sms.rawValue,
                                          channel: state.notificationPreference.type.rawValue,
                                          action: state.smsSwitchIsOn ? "ENABLE" : "DISABLE"),
            
            UpdatedNotificationPreference(contactMethod: NotificationMethod.push.rawValue,
                                          channel: state.notificationPreference.type.rawValue,
                                          action: state.pushSwitchIsOn ? "ENABLE" : "DISABLE"),
            
            UpdatedNotificationPreference(contactMethod: NotificationMethod.email.rawValue,
                                          channel: state.notificationPreference.type.rawValue,
                                          action: state.emailSwitchIsOn ? "ENABLE" : "DISABLE"),
            
            UpdatedNotificationPreference(contactMethod: NotificationMethod.inApp.rawValue,
                                          channel: state.notificationPreference.type.rawValue,
                                          action: state.inAppSwitchIsOn ? "ENABLE" : "DISABLE"),
        ]
        return Effect(value: .save(updatedPreferences))
    case .save:
        return .none
    case .binding:
        return .none
    }
}
.binding()
