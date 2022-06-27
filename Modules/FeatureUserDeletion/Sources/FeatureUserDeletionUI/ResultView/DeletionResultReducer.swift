import ComposableArchitecture

public enum DeletionResultModule {}

extension DeletionResultModule {
    public static var reducer: Reducer<DeletionResultState, DeletionResultAction, DeletionResultEnvironment> {
        .init { _, action, environment in
            switch action {
            case .closeFlowOnError:
                return .none
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
