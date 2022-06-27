import Combine
import FeatureUserDeletionDomain
import NetworkError

public struct WalletDeactivationRepository: WalletDeactivationRepositoryAPI {

    private let client: WalletDeactivationClientAPI

    public init(client: WalletDeactivationClientAPI) {
        self.client = client
    }

    public func deactivateWallet(
        guid: String,
        sharedKey: String,
        email: String,
        sessionToken: String
    ) -> AnyPublisher<Void, NetworkError> {
        client.deactivateWallet(
            guid: guid,
            sharedKey: sharedKey,
            email: email,
            sessionToken: sessionToken
        )
    }
}
