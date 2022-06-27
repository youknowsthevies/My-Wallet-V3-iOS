import Combine
import NetworkError

public protocol UserDeletionRepositoryAPI {
    func deleteUser(
        with reason: String?
    ) -> AnyPublisher<Void, NetworkError>
}
