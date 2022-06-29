import Combine
import Errors
import Foundation
import NetworkKit

public final class UserDeletionClient: UserDeletionClientAPI {
    public let networkAdapter: NetworkAdapterAPI
    public let requestBuilder: RequestBuilder

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    public func deleteUser(
        reason: String?
    ) -> AnyPublisher<Void, NetworkError> {
        let body = UserDeletionRequest(reason: reason)
        let request = requestBuilder.post(
            path: ["users", "account", "delete"],
            body: try? JSONEncoder().encode(body),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}
