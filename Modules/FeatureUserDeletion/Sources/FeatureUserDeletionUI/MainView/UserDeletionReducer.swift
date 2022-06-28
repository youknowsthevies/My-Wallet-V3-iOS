import ComposableArchitecture

public enum UserDeletionModule {}

extension UserDeletionModule {
    public static var reducer: Reducer<UserDeletionState, UserDeletionAction, UserDeletionEnvironment> {
        .init { state, action, environment in
            switch action {
            case .showConfirmationScreen:
                state.route = .navigate(
                    to: .showConfirmationView(
                        userDeletionRepository: environment.userDeletionRepository,
                        dismissFlow: environment.dismissFlow,
                        logoutAndForgetWallet: environment.logoutAndForgetWallet
                    )
                )
                return .none
            case .route(let routeItent):
                state.route = routeItent
                return .none
            default:
                return .none
            }
        }
        .binding()
    }
}
