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
                state.route = .navigate(
                    to: .showResultScreen(
                        success: success,
                        dismissFlow: environment.dismissFlow,
                        logoutAndForgetWallet: environment.logoutAndForgetWallet
                    )
                )
                return .none
            case .dismissFlow:
                environment.dismissFlow()
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
                        .showResultScreen(success: result.isSuccess)
                    }
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
