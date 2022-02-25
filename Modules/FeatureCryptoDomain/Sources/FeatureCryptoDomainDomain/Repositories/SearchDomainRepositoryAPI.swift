// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkError

public enum SearchDomainRepositoryError: Error {
    case networkError(NetworkError)
}

public protocol SearchDomainRepositoryAPI {
    func searchResults(
        searchKey: String
    ) -> AnyPublisher<[SearchDomainResult], SearchDomainRepositoryError>
}
