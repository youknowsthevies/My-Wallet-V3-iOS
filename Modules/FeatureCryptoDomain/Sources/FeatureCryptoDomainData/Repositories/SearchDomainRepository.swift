// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureCryptoDomainDomain

final class SearchDomainRepository: SearchDomainRepositoryAPI {

    // MARK: - Properties

    private let apiClient: SearchDomainClientAPI

    // MARK: - Setup

    init(apiClient: SearchDomainClientAPI = resolve()) {
        self.apiClient = apiClient
    }


    func searchResults(searchKey: String) -> AnyPublisher<[SearchDomainResult], SearchDomainRepositoryError> {
        apiClient
            .getSearchResults(searchKey: searchKey)
            .map { response in
                let searchedDomain = response.searchedDomain.map(SearchDomainResult.init)
                let suggestions = response.suggestions.map(SearchDomainResult.init)
                return [searchedDomain] + suggestions
            }
            .mapError(SearchDomainRepositoryError.networkError)
            .eraseToAnyPublisher()
    }
}
