// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

public protocol SearchDomainClientAPI {

    /// Get domain search results from server given a search key
    func getSearchResults(
        searchKey: String
    ) -> AnyPublisher<SearchResultResponse, NetworkError>

    /// Get free domain search results from server given a search key
    func getFreeSearchResults(
        searchKey: String
    ) -> AnyPublisher<FreeSearchResultResponse, NetworkError>
}

public final class SearchDomainClient: SearchDomainClientAPI {

    // MARK: - Type

    private enum Path {
        static let search = [
            "explorer-gateway",
            "resolution",
            "ud",
            "search"
        ]
        static let freeSearch = [
            "explorer-gateway",
            "resolution",
            "ud",
            "suggestions"
        ]
    }

    // MARK: - Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - Methods

    public func getSearchResults(
        searchKey: String
    ) -> AnyPublisher<SearchResultResponse, NetworkError> {
        let request = requestBuilder.get(
            path: Path.search + [searchKey],
            contentType: .json
        )!
        return networkAdapter.perform(request: request)
    }

    public func getFreeSearchResults(
        searchKey: String
    ) -> AnyPublisher<FreeSearchResultResponse, NetworkError> {
        let request = requestBuilder.get(
            path: Path.freeSearch + [searchKey],
            contentType: .json
        )!
        return networkAdapter.perform(request: request)
    }
}
