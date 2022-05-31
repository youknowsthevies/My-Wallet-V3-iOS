// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Product: Codable, Equatable {

    public let productCode: String

    public let price: Money

    public let brand: Card.Brand

    public let type: Card.CardType

    public init(
        productCode: String,
        price: Money,
        brand: Card.Brand,
        type: Card.CardType
    ) {
        self.productCode = productCode
        self.price = price
        self.brand = brand
        self.type = type
    }
}
