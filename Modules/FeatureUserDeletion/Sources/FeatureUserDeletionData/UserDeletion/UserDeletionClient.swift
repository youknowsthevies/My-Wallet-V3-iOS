import Combine
import NetworkError
import NetworkKit

/// https://www.notion.so/blockchaincom/Delete-User-Account-BE-5d6ffb752d9c4cc5bc5d055a235a62f1

public protocol UserDeletionClientAPI {
    func deleteUser(
        reason: String?
    ) -> AnyPublisher<Void, NetworkError>
}
