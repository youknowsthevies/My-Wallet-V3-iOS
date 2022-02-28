// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

protocol SearchDomainClientAPI {

    /// Get domain search results from server given a search key
    func getSearchResults(
        searchKey: String
    ) -> AnyPublisher<SearchResultResponse, NetworkError>
}

final class SearchDomainClient: SearchDomainClientAPI {

    // MARK: - Type

    private enum Path {
        static let search = [
            "explorer-gateway",
            "resolution",
            "ud",
            "search"
        ]
    }

    // MARK: - Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - Methods

    func getSearchResults(
        searchKey: String
    ) -> AnyPublisher<SearchResultResponse, NetworkError> {
        let request = requestBuilder.get(
            path: Path.search + [searchKey],
            contentType: .json
        )!
        return networkAdapter.perform(request: request)
    }
}
