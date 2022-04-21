//
//  NotificationPreferencesActivityTogglesView+Reducer.swift
//  FeatureBuilder
//
//  Created by Augustin Udrea on 12/04/2022.
//

import ComposableArchitecture
import Foundation

public let notificationPreferencesDetailsReducer = Reducer<
    NotificationPreferencesDetailsState,
    NotificationPreferencesDetailsAction,
    NotificationPreferencesDetailsEnvironment
> { state, action, environment in
    switch action {
    case .onDissapear:
        return .none
    case .binding:
        return .none
    }
}
.binding()
