// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import Foundation

struct ReverseResolutionResponse: Decodable {
    let domains: [DomainResponse]
}

struct DomainResponse: Decodable {
    let domain: String
    let isBlockchainDomain: Bool
}

extension ReverseResolution {
    init(from response: DomainResponse) {
        self.init(domainName: response.domain)
    }
}
