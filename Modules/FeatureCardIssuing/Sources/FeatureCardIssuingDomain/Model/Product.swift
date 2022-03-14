// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Product: Codable {

    public let productCode: String

    public let price: Money

    public let brand: Card.Brand

    public let type: Card.CardType
}
