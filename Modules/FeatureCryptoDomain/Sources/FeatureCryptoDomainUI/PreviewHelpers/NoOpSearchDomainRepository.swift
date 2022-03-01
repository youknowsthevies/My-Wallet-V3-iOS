// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCryptoDomainDomain
import ToolKit

final class NoOpSearchDomainRepository: SearchDomainRepositoryAPI {

    func searchResults(
        searchKey: String
    ) -> AnyPublisher<[SearchDomainResult], SearchDomainRepositoryError> {
        .empty()
    }
}
