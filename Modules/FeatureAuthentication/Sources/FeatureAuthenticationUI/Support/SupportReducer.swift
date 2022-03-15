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

struct SupportViewState {
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
