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
    public enum ViewState: Hashable {
        case idle
        case loading
        case data(notificationDetailsState: [NotificationPreference])
        case error
    }
    
    public var route: RouteIntent<NotificationsSettingsRoute>?
    public var viewState: ViewState
    public var notificationDetailsState: NotificationSettingsDetailsState?
    //    public var isLoading: Bool
    
    public var notificationPrefrences: [NotificationPreference]?
    
    public init(route: RouteIntent<NotificationsSettingsRoute>? = nil,
                viewState: ViewState,
                isLoading: Bool = true) {
        self.route = route
        self.viewState = viewState
        //        self.notificationPrefrences = notificationPreferences
        //        self.isLoading = isLoading
    }
}

public enum NotificationSettingsAction: Equatable, NavigationAction {
    case onAppear
    case onDisappear
    case onReloadTap
    case onPreferenceSelected(NotificationPreference)
    case notificationDetailsChanged(NotificationSettingsDetailsAction)
    case onFetchedSettings(Result<[NotificationPreference], NetworkError>)
    case route(RouteIntent<NotificationsSettingsRoute>?)
}

public enum NotificationsSettingsRoute: NavigationRoute {
    case showDetails(notificationPreference: NotificationPreference)
    
    public func destination(in store: Store<NotificationSettingsState, NotificationSettingsAction>) -> some View {
        switch self {
            
        case .showDetails(let preference):
            return IfLetStore(
                store.scope(
                    state: \.notificationDetailsState,
                    action: NotificationSettingsAction.notificationDetailsChanged
                ),
                then: { store in
                    NotificationSettingsDetailsView(store: store)
                }
            )
            
            //            return NotificationSettingsDetailsView(store: .init(initialState:
            //                    .init(notificationPreference: preference),
            //                                                                reducer: notificationSettingsDetailsReducer,
            //                                                                environment: NotificationSettingsDetailsEnvironment()))
        }
    }
}


let featureReducer = Reducer<NotificationSettingsState, NotificationSettingsAction, FeatureNotificationSettingsEnvironment>.combine(
    notificationSettingsDetailsReducer
        .optional()
        .pullback(
            state: \.notificationDetailsState,
            action: /NotificationSettingsAction.notificationDetailsChanged,
            environment: { environment -> NotificationSettingsDetailsEnvironment in
                NotificationSettingsDetailsEnvironment()
            }
        ),
    featureNotificationReducer
)

public let featureNotificationReducer = Reducer<
    NotificationSettingsState,
    NotificationSettingsAction,
    FeatureNotificationSettingsEnvironment
> { state, action, environment in
    
    switch action {
    case .onAppear:
        state.viewState = .loading
        return environment
            .notificationSettingsRepository
            .fetchSettings()
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(NotificationSettingsAction.onFetchedSettings)
        
        
    case .route(let routeItent):
        state.route = routeItent
        return .none
        
    case .onDisappear:
        return .none
        
    case .onReloadTap:
        state.viewState = .loading
        return environment
            .notificationSettingsRepository
            .fetchSettings()
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(NotificationSettingsAction.onFetchedSettings)
        
    case .notificationDetailsChanged(let action):
        print(action)
        return .none
        
    case .onPreferenceSelected(let preference):
        state.notificationDetailsState = NotificationSettingsDetailsState(notificationPreference: preference)
        return .none
        
    case .onFetchedSettings(let result):
        switch result {
        case .success(let preferences) :
            state.viewState = .data(notificationDetailsState: preferences)
            return .none
            
        case .failure(let error):
            state.viewState = .error
            return .none
        }
    }
}


public struct FeatureNotificationSettingsEnvironment {
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let notificationSettingsRepository: NotificationSettingsRepositoryAPI
    
    public init(mainQueue: AnySchedulerOf<DispatchQueue>,
                notificationSettingsRepository: NotificationSettingsRepositoryAPI) {
        self.mainQueue = mainQueue
        self.notificationSettingsRepository = notificationSettingsRepository
    }
}
