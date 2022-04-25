// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import Foundation
import FeatureNotificationPreferencesDomain

internal struct Switch: Equatable,Hashable {
    var method: NotificationMethod
    var isOn: Bool
}

public struct NotificationPreferencesDetailsState: Equatable, Hashable {
    public let notificationPreference: NotificationPreference
    @BindableState var pushSwitch: Switch = Switch(method: .push, isOn: false)
    @BindableState var emailSwitch: Switch = Switch(method: .email, isOn: false)
    @BindableState var smsSwitch: Switch = Switch(method: .sms, isOn: false)
    @BindableState var inAppSwitch: Switch = Switch(method: .inApp, isOn: false)
    
    public init(notificationPreference: NotificationPreference) {
        self.notificationPreference = notificationPreference
        
        for methodInfo in notificationPreference.enabledMethods {
            switch methodInfo.method {
            case .email:
                pushSwitch.isOn = true
            case .inApp:
                inAppSwitch.isOn = true
            case .push:
                pushSwitch.isOn = true
            case .sms:
                smsSwitch.isOn = true
            }
        }
    }
    
    public var updatedPreferences: UpdatedPreferences {
        let preferences = [pushSwitch, emailSwitch, smsSwitch, inAppSwitch]
            .filter({ controlSwitch in
                let availableMethods = notificationPreference.allAvailableMethods.compactMap{$0.method}
                return availableMethods.contains(controlSwitch.method)
            })
            .map{( UpdatedNotificationPreference(contactMethod: $0.method.rawValue,
                                                 channel: notificationPreference.type.rawValue,
                                                 action: $0.isOn ? "ENABLE" : "DISABLE"))}
        return UpdatedPreferences(preferences: preferences)
    }
}

public enum NotificationPreferencesDetailsAction: Equatable, BindableAction {
    case save
    case binding(BindingAction<NotificationPreferencesDetailsState>)
}

public struct NotificationPreferencesDetailsEnvironment{
    public init() {
        
    }
}
