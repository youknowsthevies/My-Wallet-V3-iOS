// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureTransactionDomain
import NetworkError

final class MockBlockchainNameResolutionRepository: BlockchainNameResolutionRepositoryAPI {

    var underlyingResolve: (
        _ domainName: String,
        _ currency: String
    ) -> AnyPublisher<DomainResolution, NetworkError> = { _, currency in
        .just(.init(currency: currency, address: "address"))
    }

    func resolve(
        domainName: String,
        currency: String
    ) -> AnyPublisher<DomainResolution, NetworkError> {
        underlyingResolve(domainName, currency)
    }
}
