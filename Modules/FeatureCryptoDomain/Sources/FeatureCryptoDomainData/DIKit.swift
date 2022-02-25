// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureCryptoDomainDomain

extension DependencyContainer {

    // MARK: - FeatureCryptoDomainData Module

    public static var featureCryptoDomainData = module {

        factory { SearchDomainClient() as SearchDomainClientAPI }

        factory { SearchDomainRepository() as SearchDomainRepositoryAPI }
    }
}
