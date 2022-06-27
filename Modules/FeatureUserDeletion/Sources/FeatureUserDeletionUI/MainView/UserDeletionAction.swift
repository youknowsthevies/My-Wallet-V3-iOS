import ComposableArchitecture
import ComposableNavigation

public enum UserDeletionAction: Equatable, BindableAction, NavigationAction {
    case binding(BindingAction<UserDeletionState>)
    case onAppear
    case showConfirmationScreen
    case route(RouteIntent<UserDeletionRoute>?)
}
