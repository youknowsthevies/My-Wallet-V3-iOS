//
//  NotificationPreferencesActivityTogglesView.swift
//  FeatureBuilder
//
//  Created by Augustin Udrea on 12/04/2022.
//

import ComposableArchitecture
import Foundation
import FeatureNotificationPreferencesDomain

public struct NotificationPreferencesDetailsState: Equatable, Hashable {
    public let notificationPreference: NotificationPreference
    @BindableState var pushSwitchIsOn: Bool = false
    @BindableState var emailSwitchIsOn: Bool = false
    @BindableState var smsSwitchIsOn: Bool = false
    @BindableState var inAppSwitchIsOn: Bool = false
    
    public init(notificationPreference: NotificationPreference) {
        self.notificationPreference = notificationPreference
        
        for methodInfo in notificationPreference.enabledMethods {
            switch methodInfo.method {
            case .email:
                emailSwitchIsOn = true
            case .inApp:
                inAppSwitchIsOn = true
            case .push:
                pushSwitchIsOn = true
            case .sms:
                smsSwitchIsOn = true
            }
        }
    }
}

public enum NotificationPreferencesDetailsAction: Equatable, BindableAction {
    case onDissapear
    case save([UpdatedNotificationPreference])
    case binding(BindingAction<NotificationPreferencesDetailsState>)
}

public struct NotificationPreferencesDetailsEnvironment{
    public init() {
        
    }
}
