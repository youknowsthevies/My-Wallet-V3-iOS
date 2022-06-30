import Combine
import Errors
import FeatureUserDeletionDomain

public struct UserDeletionRepository: UserDeletionRepositoryAPI {

    private let client: UserDeletionClientAPI

    public init(client: UserDeletionClientAPI) {
        self.client = client
    }

    public func deleteUser(
        with reason: String?
    ) -> AnyPublisher<Void, NetworkError> {
        client.deleteUser(reason: reason)
    }
}
