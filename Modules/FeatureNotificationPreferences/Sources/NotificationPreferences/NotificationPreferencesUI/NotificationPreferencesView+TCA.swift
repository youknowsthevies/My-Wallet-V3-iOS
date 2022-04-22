//
//  FeatureNotificationPreferences.swift
//  FeatureBuilder
//
//  Created by Augustin Udrea on 08/04/2022.
//

import Foundation
import ComposableArchitecture
import ComposableNavigation
import SwiftUI
import FeatureNotificationPreferencesDomain
import NetworkError
import FeatureNotificationPreferencesDetailsUI

public struct NotificationPreferencesState: Hashable, NavigationState {
    public enum ViewState: Equatable, Hashable {
        public static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading), (.data, .data), (.error, .error):
                return true
            default:
                return false
            }
        }
        case idle
        case loading
        case data(notificationDetailsState: [NotificationPreference])
        case error
    }
    
    public var route: RouteIntent<NotificationsSettingsRoute>?
    public var viewState: ViewState
    public var notificationDetailsState: NotificationPreferencesDetailsState?
    
    public var notificationPrefrences: [NotificationPreference]?
    
    public init(route: RouteIntent<NotificationsSettingsRoute>? = nil,
                notificationDetailsState: NotificationPreferencesDetailsState? = nil,
                viewState: ViewState) {
        self.route = route
        self.notificationDetailsState = notificationDetailsState
        self.viewState = viewState
    }
}

public enum NotificationPreferencesAction: Equatable, NavigationAction {
    case onAppear
    case onDisappear
    case onReloadTap
    case onPreferenceSelected(NotificationPreference)
    case notificationDetailsChanged(NotificationPreferencesDetailsAction)
    case onFetchedSettings(Result<[NotificationPreference], NetworkError>)
    case route(RouteIntent<NotificationsSettingsRoute>?)
}

public enum NotificationsSettingsRoute: NavigationRoute {
    case showDetails
    
    public func destination(in store: Store<NotificationPreferencesState, NotificationPreferencesAction>) -> some View {
        switch self {
            
        case .showDetails:
            return IfLetStore(
                store.scope(
                    state: \.notificationDetailsState,
                    action: NotificationPreferencesAction.notificationDetailsChanged
                ),
                then: { store in
                    NotificationPreferencesDetailsView(store: store)
                }
            )
        }
    }
}


let featureReducer = Reducer<NotificationPreferencesState, NotificationPreferencesAction, FeatureNotificationPreferencesEnvironment>.combine(
    notificationPreferencesDetailsReducer
        .optional()
        .pullback(
            state: \.notificationDetailsState,
            action: /NotificationPreferencesAction.notificationDetailsChanged,
            environment: { environment -> NotificationPreferencesDetailsEnvironment in
                NotificationPreferencesDetailsEnvironment()
            }
        ),
    featureNotificationReducer
)

public let featureNotificationReducer = Reducer<
    NotificationPreferencesState,
    NotificationPreferencesAction,
    FeatureNotificationPreferencesEnvironment
> { state, action, environment in
    
    switch action {
    case .onAppear:
        state.viewState = .loading
        
        return environment
            .notificationPreferencesRepository
            .fetchPreferences()
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(NotificationPreferencesAction.onFetchedSettings)
        
    case .route(let routeItent):
        state.route = routeItent
        return .none
        
    case .onDisappear:
        return .none
        
    case .onReloadTap:
        return environment
            .notificationPreferencesRepository
            .fetchPreferences()
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(NotificationPreferencesAction.onFetchedSettings)
        
    case .notificationDetailsChanged(let action):
        switch action {
        case .save:
            guard let preferences = state.notificationDetailsState?.updatedPreferences else { return .none }
            return  environment
                    .notificationPreferencesRepository
                    .update(preferences: preferences)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map({ update in
                        NotificationPreferencesAction.onReloadTap
                    })
            
        case .binding:
            return .none
        }
        
    case .onPreferenceSelected(let preference):
        state.notificationDetailsState = NotificationPreferencesDetailsState(notificationPreference: preference)
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


public struct FeatureNotificationPreferencesEnvironment {
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let notificationPreferencesRepository: NotificationPreferencesRepositoryAPI

    public init(mainQueue: AnySchedulerOf<DispatchQueue>,
                notificationPreferencesRepository: NotificationPreferencesRepositoryAPI) {
        self.mainQueue = mainQueue
        self.notificationPreferencesRepository = notificationPreferencesRepository
    }
}
