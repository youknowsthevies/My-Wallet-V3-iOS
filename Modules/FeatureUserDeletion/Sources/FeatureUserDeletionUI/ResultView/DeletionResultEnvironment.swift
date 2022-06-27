import ComposableArchitecture

public struct DeletionResultEnvironment {
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let logoutAndForgetWallet: () -> Void

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        logoutAndForgetWallet: @escaping () -> Void
    ) {
        self.mainQueue = mainQueue
        self.logoutAndForgetWallet = logoutAndForgetWallet
    }
}
