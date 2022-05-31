// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkKit

public protocol AttributionClientAPI {
    func fetchWebsocketEvents() -> AnyPublisher<WebsocketEvent, NetworkError>
}

public class AttributionClient: AttributionClientAPI {
    // MARK: - Private Properties

    private enum Path {
        static let conversion = ["events", "conversion"]
    }

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    public func fetchWebsocketEvents() -> AnyPublisher<WebsocketEvent, NetworkError> {
        let networkRequest = requestBuilder.get(
            path: Path.conversion,
            authenticated: true
        )!

        return networkAdapter
            .performWebsocket(request: networkRequest)
    }
}
