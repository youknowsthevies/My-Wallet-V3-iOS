import Combine
import Errors

public protocol UserDeletionRepositoryAPI {
    func deleteUser(
        with reason: String?
    ) -> AnyPublisher<Void, NetworkError>
}
