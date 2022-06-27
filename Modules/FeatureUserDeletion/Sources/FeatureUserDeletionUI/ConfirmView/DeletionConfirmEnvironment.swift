import ComposableArchitecture
import FeatureUserDeletionDomain

public struct DeletionConfirmEnvironment {
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let walletDeactivationConfig: WalletDeactivationConfig
    public let userDeletionRepository: UserDeletionRepositoryAPI
    public let walletDeactivationRepository: WalletDeactivationRepositoryAPI
    public let logoutAndForgetWallet: () -> Void

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        walletDeactivationConfig: WalletDeactivationConfig,
        userDeletionRepository: UserDeletionRepositoryAPI,
        walletDeactivationRepository: WalletDeactivationRepositoryAPI,
        logoutAndForgetWallet: @escaping () -> Void
    ) {
        self.mainQueue = mainQueue
        self.walletDeactivationConfig = walletDeactivationConfig
        self.userDeletionRepository = userDeletionRepository
        self.walletDeactivationRepository = walletDeactivationRepository
        self.logoutAndForgetWallet = logoutAndForgetWallet
    }
}
