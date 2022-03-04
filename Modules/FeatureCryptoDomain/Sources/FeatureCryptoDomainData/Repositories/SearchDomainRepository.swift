// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCryptoDomainDomain
import Foundation
import OrderedCollections

final class SearchDomainRepository: SearchDomainRepositoryAPI {

    // MARK: - Properties

    private let apiClient: SearchDomainClientAPI
    private let queue = DispatchQueue(label: "SearchDomainRepository")

    // MARK: - Setup

    init(apiClient: SearchDomainClientAPI) {
        self.apiClient = apiClient
    }

    func searchResults(searchKey: String) -> AnyPublisher<[SearchDomainResult], SearchDomainRepositoryError> {
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
