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
                let walletDeactivationConfig = environment.walletDeactivationConfig
                state.route = .navigate(
                    to: .showConfirmationView(
                        walletDeactivationConfig: walletDeactivationConfig,
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
