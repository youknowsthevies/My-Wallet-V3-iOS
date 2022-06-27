import ComposableArchitecture

public enum UserDeletionModule {}

extension UserDeletionModule {
    public static var reducer: Reducer<UserDeletionState, UserDeletionAction, UserDeletionEnvironment> {
        .init { state, action, environment in
            switch action {
            case .showConfirmationScreen:
                let logoutAndForgetWallet = environment.logoutAndForgetWallet
                let userDeletionRepository = environment.userDeletionRepository
                let walletDeactivationRepository = environment.walletDeactivationRepository
                state.route = .navigate(
                    to: .showConfirmationView(
                        userDeletionRepository: userDeletionRepository,
                        walletDeactivationRepository: walletDeactivationRepository,
                        logoutAndForgetWallet: logoutAndForgetWallet
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
