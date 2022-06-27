import Combine
import NetworkKit

public final class WalletDeactivationClient: WalletDeactivationClientAPI {
    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    public func deactivateWallet(
        guid: String,
        sharedKey: String,
        email: String,
        sessionToken: String
    ) -> AnyPublisher<Void, NetworkError> {
        let data = WalletDeactivationRequest(
            guid: guid,
            sharedKey: sharedKey,
            email: email
        )

        let request = requestBuilder.post(
            path: ["wallet"],
            body: RequestBuilder.body(from: data.parameters),
            headers: [
                "Authorization": "Bearer \(sessionToken)"
            ],
            contentType: .formUrlEncoded
        )!

        return networkAdapter
            .perform(request: request)
            .eraseToAnyPublisher()
    }
}
