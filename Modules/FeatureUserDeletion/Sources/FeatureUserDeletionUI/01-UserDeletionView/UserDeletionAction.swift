import ComposableArchitecture
import ComposableNavigation

public enum UserDeletionAction: Equatable, BindableAction, NavigationAction {
    case binding(BindingAction<UserDeletionState>)
    case dismissFlow
    case onAppear
    case onConfirmViewChanged(DeletionConfirmAction)
    case route(RouteIntent<UserDeletionRoute>?)
    case showConfirmationScreen
}
