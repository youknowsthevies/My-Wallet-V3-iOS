import ComposableArchitecture
import FeatureUserDeletionDomain

public struct DeletionConfirmEnvironment {
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let userDeletionRepository: UserDeletionRepositoryAPI
    public let walletDeactivationRepository: WalletDeactivationRepositoryAPI
    public let logoutAndForgetWallet: () -> Void

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        userDeletionRepository: UserDeletionRepositoryAPI,
        walletDeactivationRepository: WalletDeactivationRepositoryAPI,
        logoutAndForgetWallet: @escaping () -> Void
    ) {
        self.mainQueue = mainQueue
        self.userDeletionRepository = userDeletionRepository
        self.walletDeactivationRepository = walletDeactivationRepository
        self.logoutAndForgetWallet = logoutAndForgetWallet
    }
}
