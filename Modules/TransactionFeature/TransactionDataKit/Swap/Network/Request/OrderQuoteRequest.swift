// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import TransactionKit

extension TransactionKit.Product: Codable {}

struct OrderQuoteRequest: Encodable {

    let product: TransactionKit.Product
    let direction: TransactionKit.OrderDirection
    let pair: TransactionKit.OrderPair

    enum CodingKeys: CodingKey {
        case product
        case direction
        case pair
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(product, forKey: .product)
        try container.encode(direction, forKey: .direction)
        try container.encode(pair.rawValue, forKey: .pair)
    }
}
