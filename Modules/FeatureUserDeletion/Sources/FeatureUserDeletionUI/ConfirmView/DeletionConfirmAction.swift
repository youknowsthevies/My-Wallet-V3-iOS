import ComposableArchitecture
import ComposableNavigation

public enum DeletionConfirmAction: Equatable, BindableAction, NavigationAction {
    case binding(BindingAction<DeletionConfirmState>)
    case onAppear
    case showResultScreen(success: Bool)
    case deleteUserAccount
    case deactivateWallet
    case route(RouteIntent<UserDeletionResultRoute>?)
    case validateConfirmationInput
}
