import ComposableArchitecture

public enum DeletionResultModule {}

extension DeletionResultModule {
    public static var reducer: Reducer<DeletionResultState, DeletionResultAction, DeletionResultEnvironment> {
        .init { _, action, environment in
            switch action {
            case .dismissFlow:
                return .fireAndForget {
                    environment.dismissFlow()
                }
            case .logoutAndForgetWallet:
                return .fireAndForget {
                    environment.logoutAndForgetWallet()
                }
            default:
                return .none
            }
        }
        .binding()
    }
}
