import Combine
import ComposableArchitecture
import ComposableNavigation
import FeatureUserDeletionDomain

public enum DeletionConfirmModule {}

extension DeletionConfirmModule {
    public static var reducer: Reducer<DeletionConfirmState, DeletionConfirmAction, DeletionConfirmEnvironment> {
        .init { state, action, environment in
            switch action {
            case .showResultScreen(let success):
                let logoutAndForgetWallet = environment.logoutAndForgetWallet
                state.route = .navigate(
                    to: .showResultScreen(
                        success: success,
                        logoutAndForgetWallet: logoutAndForgetWallet
                    )
                )
                return .none
            case .route(let routeItent):
                state.route = routeItent
                return .none
            case .deleteUserAccount:
                guard state.isConfirmationInputValid else {
                    return Effect(value: .validateConfirmationInput)
                }
                state.isLoading = true
                return environment
                    .userDeletionRepository
                    .deleteUser(with: nil)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { result -> DeletionConfirmAction in
                        if case .failure = result {
                            return DeletionConfirmAction.showResultScreen(success: false)
                        }
                        return DeletionConfirmAction.deactivateWallet
                    }
            case .deactivateWallet:
                let config = environment.walletDeactivationConfig
                return .merge(
                    environment
                        .walletDeactivationRepository
                        .deactivateWallet(
                            guid: config.guid,
                            sharedKey: config.sharedKey,
                            email: config.email,
                            sessionToken: config.sessionToken
                        )
                        .fireAndForget(),
                    Effect(value: DeletionConfirmAction.showResultScreen(success: true))
                )
            case .binding(\.$textFieldText):
                return Effect(value: .validateConfirmationInput)
            case .validateConfirmationInput:
                state.validateConfirmationInputField()
                return .none
            default:
                return .none
            }
        }
        .binding()
    }
}
