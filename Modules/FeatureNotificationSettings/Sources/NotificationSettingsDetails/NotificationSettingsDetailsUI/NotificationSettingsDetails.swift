//
//  NotificationSettingsActivityTogglesView.swift
//  FeatureBuilder
//
//  Created by Augustin Udrea on 12/04/2022.
//

import ComposableArchitecture
import Foundation
import FeatureNotificationSettingsDomain

public struct NotificationSettingsDetailsState: Equatable {
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

public enum NotificationSettingsDetailsAction: Equatable, BindableAction {
    case onDissapear
    case binding(BindingAction<NotificationSettingsDetailsState>)
}

public struct NotificationSettingsDetailsEnvironment{
    public init() {
        
    }
}
