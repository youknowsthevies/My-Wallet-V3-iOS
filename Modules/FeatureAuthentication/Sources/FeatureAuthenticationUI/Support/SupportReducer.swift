import AnalyticsKit
import Combine
import ComposableArchitecture
import ComposableNavigation
import FeatureAuthenticationDomain
import ToolKit

enum SupportViewAction: Equatable, BindableAction {
    case binding(BindingAction<SupportViewState>)
//    case route(RouteIntent<>?)
}

struct SupportViewState: Equatable {
    @BindableState var isSupportViewSheetShown = false
}

let supportViewReducer = Reducer<
    SupportViewState,
    SupportViewAction,
    Void
> { state, action, _ in
    switch action {
    case .binding(.set(\.$isSupportViewSheetShown, true)):
        return .none
    case .binding(.set(\.$isSupportViewSheetShown, false)):
        return .none
    case .binding:
        return .none
    }
}
.binding()

struct SupportViewEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
}

extension SupportViewEnvironment {
    static let `default`: SupportViewEnvironment = .init(
        mainQueue: .main
    )
}
