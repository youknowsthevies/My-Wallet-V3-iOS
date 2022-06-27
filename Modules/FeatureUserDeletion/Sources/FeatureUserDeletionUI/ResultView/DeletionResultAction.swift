import ComposableArchitecture

public enum DeletionResultAction: Equatable, BindableAction {
    case binding(BindingAction<DeletionResultState>)
    case onAppear
    case closeFlowOnError
    case logoutAndForgetWallet
}
