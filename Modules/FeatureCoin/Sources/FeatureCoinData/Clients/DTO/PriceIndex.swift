// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct PriceIndex: Hashable, Decodable {

    public let price: Double
    public let timestamp: Date

    public init(price: Double, timestamp: Date) {
        self.price = price
        self.timestamp = timestamp
    }
}
