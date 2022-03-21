// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCryptoDomainDomain
import Foundation
import OrderedCollections

public final class SearchDomainRepository: SearchDomainRepositoryAPI {

    // MARK: - Properties

    private let apiClient: SearchDomainClientAPI

    // MARK: - Setup

    public init(apiClient: SearchDomainClientAPI) {
        self.apiClient = apiClient
    }

    public func searchResults(searchKey: String) -> AnyPublisher<[SearchDomainResult], SearchDomainRepositoryError> {
        apiClient
            .getSearchResults(searchKey: searchKey)
            .map { response in
                let searchedDomain = SearchDomainResult(from: response.searchedDomain)
                let suggestions = response.suggestions.map(SearchDomainResult.init)
                let results = OrderedSet([searchedDomain] + suggestions)
                return Array(results)
            }
            .mapError(SearchDomainRepositoryError.networkError)
            .eraseToAnyPublisher()
    }
}
