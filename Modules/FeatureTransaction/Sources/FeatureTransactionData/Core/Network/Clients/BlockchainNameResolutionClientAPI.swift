// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkError

protocol BlockchainNameResolutionClientAPI {

    func resolve(
        domainName: String,
        currency: String
    ) -> AnyPublisher<DomainResolutionResponse, NetworkError>

    func reverseResolve(
        address: String
    ) -> AnyPublisher<ReverseResolutionResponse, NetworkError>
}
