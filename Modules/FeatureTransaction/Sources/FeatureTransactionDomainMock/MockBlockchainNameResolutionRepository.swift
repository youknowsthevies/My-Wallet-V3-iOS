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

    var underlyingReverseResolve: (
        _ address: String
    ) -> AnyPublisher<[ReverseResolution], NetworkError> = { _ in
        .just([.init(domainName: "domainName")])
    }

    func resolve(
        domainName: String,
        currency: String
    ) -> AnyPublisher<DomainResolution, NetworkError> {
        underlyingResolve(domainName, currency)
    }

    func reverseResolve(
        address: String
    ) -> AnyPublisher<[ReverseResolution], NetworkError> {
        underlyingReverseResolve(address)
    }
}
