// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import ComposableNavigation
import DIKit
import FeatureAuthenticationDomain
import ToolKit

enum SupportViewAction: Equatable, NavigationAction {
    case loadAppStoreVersionInformation
    case failedToRetrieveAppStoreInfo
    case appStoreVersionInformationReceived(AppStoreApplicationInfo)
    case route(RouteIntent<SupportViewRoute>?)
}

struct SupportViewState: Equatable, NavigationState {
    let applicationVersion: String
    let bundleIdentifier: String
    var appStoreVersion: String?
    var isApplicationUpdated: Bool
    var route: RouteIntent<SupportViewRoute>?

    init(
        applicationVersion: String,
        bundleIdentifier: String
    ) {
        self.applicationVersion = applicationVersion
        self.bundleIdentifier = bundleIdentifier
        appStoreVersion = nil
        isApplicationUpdated = true
    }
}

let supportViewReducer = Reducer<
    SupportViewState,
    SupportViewAction,
    SupportViewEnvironment
> { state, action, environment in
    switch action {
    case .loadAppStoreVersionInformation:
        return environment
            .appStoreInformationRepository
            .verifyTheCurrentAppVersionIsTheLatestVersion(
                state.applicationVersion,
                bundleId: "com.rainydayapps.Blockchain"
            )
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result -> SupportViewAction in
                guard let applicationInfo = result.successData else {
                    return .failedToRetrieveAppStoreInfo
                }
                return .appStoreVersionInformationReceived(applicationInfo)
            }
    case .appStoreVersionInformationReceived(let applicationInfo):
        state.isApplicationUpdated = applicationInfo.isApplicationUpToDate
        state.appStoreVersion = applicationInfo.version
        return .none
    case .route(let route):
        state.route = route
        return .none
    case .failedToRetrieveAppStoreInfo:
        return .none
    }
}

struct SupportViewEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let appStoreInformationRepository: AppStoreInformationRepositoryAPI
}

extension SupportViewEnvironment {
    static let `default`: SupportViewEnvironment = .init(
        mainQueue: .main,
        appStoreInformationRepository: resolve()
    )
}
