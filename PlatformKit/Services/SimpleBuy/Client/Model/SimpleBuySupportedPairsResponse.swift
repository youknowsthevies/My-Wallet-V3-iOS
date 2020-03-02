//
//  SimpleBuySupportedPairsResponse.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

/// A response for `simple-buy/pairs`
public struct SimpleBuySupportedPairsResponse: Decodable {
    
    // MARK: - Types
    
    struct Pair: Decodable {
        
        /// Possible pair with the format: `BTC-USD`
        let pair: String

        /// Min fiat amount to buy (`1000` ~ 10.00 Fiat)
        let buyMin: String
        
        /// Max fiat amount to buy (`100000` ~ 1000.00 Fiat)
        let buyMax: String
    }
    
    /// The pairs
    let pairs: [Pair]
}
