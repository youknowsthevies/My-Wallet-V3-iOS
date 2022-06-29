import ComposableArchitecture
import ComposableNavigation

public enum DeletionConfirmAction: Equatable, BindableAction, NavigationAction {
    case binding(BindingAction<DeletionConfirmState>)
    case deleteUserAccount
    case dismissFlow
    case onAppear
    case onConfirmViewChanged(DeletionResultAction)
    case route(RouteIntent<UserDeletionResultRoute>?)
    case showResultScreen(success: Bool)
    case validateConfirmationInput
}
