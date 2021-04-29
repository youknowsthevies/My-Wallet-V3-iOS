// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import NetworkKit

/// Model for a quoted price by the Service-Price endpoint in fiat for a single asset type.
public struct PriceQuoteAtTimeResponse: Decodable, Equatable {
    
    public static let empty = PriceQuoteAtTimeResponse(timestamp: .distantPast, price: 0, volume24h: nil)
    
    public let timestamp: Date
    public let price: Decimal
    public let volume24h: Decimal?
    
    public static func ==(lhs: PriceQuoteAtTimeResponse, rhs: PriceQuoteAtTimeResponse) -> Bool {
        lhs.timestamp == rhs.timestamp
            && lhs.price == rhs.price
            && lhs.volume24h == rhs.volume24h
    }
    
    public init(timestamp: Date, price: Decimal, volume24h: Decimal?) {
        self.timestamp = timestamp
        self.price = price
        self.volume24h = volume24h
    }
}
