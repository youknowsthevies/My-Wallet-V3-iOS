// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

public protocol OrderDomainClientAPI {

    func postOrder(
        payload: PostOrderRequest
    ) -> AnyPublisher<PostOrderResponse, NetworkError>
}

public final class OrderDomainClient: OrderDomainClientAPI {

    // MARK: - Type

    private enum Path {
        static let order = [
            "explorer-gateway",
            "resolution",
            "ud",
            "orders"
        ]
    }

    // MARK: - Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - API

    public func postOrder(
        payload: PostOrderRequest
    ) -> AnyPublisher<PostOrderResponse, NetworkError> {
        let request = requestBuilder.post(
            path: Path.order,
            body: try? payload.encode(),
            contentType: .json
        )!
        return networkAdapter.perform(request: request)
    }
}
