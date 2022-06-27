import Combine
import NetworkError

public protocol WalletDeactivationRepositoryAPI {
    func deactivateWallet(
        guid: String,
        sharedKey: String,
        email: String,
        sessionToken: String
    ) -> AnyPublisher<Void, NetworkError>
}
