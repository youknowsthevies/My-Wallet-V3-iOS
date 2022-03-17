import AnalyticsKit
import Combine
import ComposableArchitecture
import ComposableNavigation
import DIKit
import FeatureAuthenticationDomain
import ToolKit

enum SupportViewAction: Equatable, BindableAction {
    case loadAppStoreVersionInformation
    case failedToRetrieveAppStoreInfo
    case appStoreVersionInformationReceived(AppStoreApplicationInfo)
    case binding(BindingAction<SupportViewState>)
//    case route(RouteIntent<>?)
}

struct SupportViewState: Equatable {
    @BindableState var isSupportViewSheetShown = true
    let applicationVersion: String
    let bundleIdentifier: String
    var appStoreVersion: String?
    var isApplicationUpdated: Bool

    init(
        applicationVersion: String,
        bundleIdentifier: String
    ) {
        self.applicationVersion = applicationVersion
        self.bundleIdentifier = bundleIdentifier
        self.appStoreVersion = nil
        self.isApplicationUpdated = true
    }
}

let supportViewReducer = Reducer<
    SupportViewState,
    SupportViewAction,
    SupportViewEnvironment
> { state, action, environment in
    switch action {
    case .binding(.set(\.$isSupportViewSheetShown, true)):
        return .none
    case .binding(.set(\.$isSupportViewSheetShown, false)):
        return .none
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
    case .failedToRetrieveAppStoreInfo:
        return .none
    case .binding:
        return .none
    }
}
.binding()

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
