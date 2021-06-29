// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import TransactionKit

struct DomainResolutionResponse: Decodable {
    let currency: String
    let address: String
}

extension DomainResolution {

    init(response: DomainResolutionResponse) {
        self.init(currency: response.currency, address: response.address)
    }
}
