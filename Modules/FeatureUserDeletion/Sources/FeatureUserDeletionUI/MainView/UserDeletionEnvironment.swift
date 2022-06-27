import ComposableArchitecture
import FeatureUserDeletionDomain

public struct WalletDeactivationConfig {
    public let guid: String
    public let sharedKey: String
    public let email: String
    public let sessionToken: String

    public init(
        guid: String,
        sharedKey: String,
        email: String,
        sessionToken: String
    ) {
        self.guid = guid
        self.sharedKey = sharedKey
        self.email = email
        self.sessionToken = sessionToken
    }
}

public struct UserDeletionEnvironment {
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
