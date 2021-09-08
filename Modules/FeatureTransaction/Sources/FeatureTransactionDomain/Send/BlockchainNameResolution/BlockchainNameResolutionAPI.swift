//  Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkError

public struct DomainResolution {
    let currency: String
    let address: String

    public init(currency: String, address: String) {
        self.currency = currency
        self.address = address
    }
}

public protocol BlockchainNameResolutionRepositoryAPI {

    func resolve(
        domainName: String,
        currency: String
    ) -> AnyPublisher<DomainResolution, NetworkError>
}
