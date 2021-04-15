//
//  PriceQuoteAtTime.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

public struct PriceQuoteAtTime: Equatable {
    
    /// The time stamp of the quote
    public let timestamp: Date
    
    /// The volume over 24 hours
    public let volume24h: Decimal?
    
    /// The quote value
    public let moneyValue: MoneyValue
}

extension PriceQuoteAtTime {
    
    /// Initialize the quote with the network response
    /// - Parameters:
    ///   - response: The quote response
    ///   - currency: The conversion currency of the quote
    /// - Throws: Money value initialization error.
    public init(response: PriceQuoteAtTimeResponse, currency: Currency) throws {
        self.moneyValue = MoneyValue.create(major: "\(response.price)", currency: currency.currency)!
        self.volume24h = response.volume24h
        self.timestamp = response.timestamp
    }
}
