// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public enum SearchDomainRepositoryError: Equatable, Error {
    case networkError(NetworkError)
}

public protocol SearchDomainRepositoryAPI {
    func searchResults(
        searchKey: String,
        freeOnly: Bool
    ) -> AnyPublisher<[SearchDomainResult], SearchDomainRepositoryError>
}
