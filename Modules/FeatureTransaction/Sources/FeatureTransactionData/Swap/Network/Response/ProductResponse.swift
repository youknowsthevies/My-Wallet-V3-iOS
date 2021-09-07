// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain

enum ProductResponse: String, Codable {
    case brokerage = "BROKERAGE"
    case simplebuy = "SIMPLEBUY"
}

extension ProductType {

    init(response: ProductResponse) {
        switch response {
        case .brokerage:
            self = .brokerage
        case .simplebuy:
            self = .simplebuy
        }
    }
}
