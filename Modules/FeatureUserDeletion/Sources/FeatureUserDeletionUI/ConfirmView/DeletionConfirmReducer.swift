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
                state.validateConfirmationInputField()
                guard state.isConfirmationInputValid else {
                    return .none
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
                return environment
                    .walletDeactivationRepository
                    .deactivateWallet(guid: "", sharedKey: "", email: "", sessionToken: "")
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { result -> DeletionConfirmAction in
                        if case .failure = result {
                            return DeletionConfirmAction.showResultScreen(success: false)
                        }
                        return DeletionConfirmAction.showResultScreen(success: true)
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
