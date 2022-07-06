// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import Foundation
import NetworkKit

public protocol WatchlistClientAPI {

    func addTags(
        _ body: WatchlistRequestPayload
    ) -> AnyPublisher<TaggedAsset, NetworkError>

    func removeTags(
        _ body: WatchlistRequestPayload
    ) -> AnyPublisher<Void, NetworkError>

    func getTags() -> AnyPublisher<WatchlistResponse, NetworkError>
}

public struct WatchlistClient: WatchlistClientAPI {

    private enum Path {
        static let watchlist = ["watchlist"]
    }

    // MARK: - Private Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder
    private let jsonEncoder: JSONEncoder

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder,
        jsonEncoder: JSONEncoder = .init()
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
        self.jsonEncoder = jsonEncoder
    }

    public func addTags(
        _ body: WatchlistRequestPayload
    ) -> AnyPublisher<TaggedAsset, NetworkError> {
        let request = requestBuilder.put(
            path: Path.watchlist,
            body: try? jsonEncoder.encode(body),
            authenticated: true
        )!
        return networkAdapter
            .perform(request: request)
    }

    public func removeTags(
        _ body: WatchlistRequestPayload
    ) -> AnyPublisher<Void, NetworkError> {
        let request = requestBuilder.delete(
            path: Path.watchlist,
            body: try? jsonEncoder.encode(body),
            authenticated: true
        )!
        return networkAdapter
            .perform(request: request)
    }

    public func getTags() -> AnyPublisher<WatchlistResponse, NetworkError> {
        let request = requestBuilder.get(
            path: Path.watchlist,
            authenticated: true
        )!
        return networkAdapter
            .perform(request: request)
    }
}
