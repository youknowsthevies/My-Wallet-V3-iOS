//
//  FeatureNotificationSettings.swift
//  FeatureBuilder
//
//  Created by Augustin Udrea on 08/04/2022.
//

import Foundation
import ComposableArchitecture
import ComposableNavigation
import SwiftUI
import FeatureNotificationSettingsDomain
import NetworkError
import FeatureNotificationSettingsDetailsUI

public struct NotificationSettingsState: Hashable, NavigationState {
    public var route: RouteIntent<NotificationsSettingsRoute>?
    public var notificationPrefrences: [NotificationPreference]?
    
    public init(route: RouteIntent<NotificationsSettingsRoute>? = nil,
                notificationPreferences: [NotificationPreference]? = nil) {
        self.route = route
        self.notificationPrefrences = notificationPreferences
    }
}

public enum NotificationSettingsAction: Equatable, NavigationAction {
    case onAppear, onDisappear
    case fetchedSettings(Result<[NotificationPreference], NetworkError>)
    case route(RouteIntent<NotificationsSettingsRoute>?)
}

public enum NotificationsSettingsRoute: NavigationRoute {
    case showDetails(notificationPreference: NotificationPreference)
    
    public func destination(in store: Store<NotificationSettingsState, NotificationSettingsAction>) -> some View {
        switch self {
            
        case .showDetails(let preference):
            return NotificationSettingsDetailsView(store: .init(initialState:
                    .init(notificationPreference: preference),
                                                                reducer: notificationSettingsDetailsReducer,
                                                                environment: NotificationSettingsDetailsEnvironment()))
        }
    }
}

public let featureNotificationReducer = Reducer<
    NotificationSettingsState,
    NotificationSettingsAction,
    FeatureNotificationSettingsEnvironment
> { state, action, environment in
    
    switch action {
    case .onAppear:
        return
            environment
                .notificationSettingsRepository
                .fetchSettings()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(NotificationSettingsAction.fetchedSettings)
          
        
    case .route(let routeItent):
        state.route = routeItent
        return .none
        
    case .onDisappear:
        return .none
        
    case .fetchedSettings(let result):
        state.notificationPrefrences = try? result.get()
        return .none
    }
}


public struct FeatureNotificationSettingsEnvironment {
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let notificationSettingsRepository: NotificationSettingsRepositoryAPI
    
    internal init(mainQueue: AnySchedulerOf<DispatchQueue>,
                  notificationSettingsRepository: NotificationSettingsRepositoryAPI) {
        self.mainQueue = mainQueue
        self.notificationSettingsRepository = notificationSettingsRepository
    }
}
