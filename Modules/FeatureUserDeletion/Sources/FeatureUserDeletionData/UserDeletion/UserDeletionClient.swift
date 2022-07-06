import Combine
import Errors
import NetworkKit

public protocol UserDeletionClientAPI {
    func deleteUser(
        reason: String?
    ) -> AnyPublisher<Void, NetworkError>
}
