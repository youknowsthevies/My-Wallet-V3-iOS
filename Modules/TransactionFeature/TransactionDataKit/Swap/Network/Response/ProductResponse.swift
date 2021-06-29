// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import TransactionKit

enum ProductResponse: String, Codable {
    case brokerage = "BROKERAGE"
}

extension Product {

    init(response: ProductResponse) {
        switch response {
        case .brokerage:
            self = .brokerage
        }
    }
}
