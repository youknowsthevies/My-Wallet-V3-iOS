//
//  BitcoinChainCoin.swift
//  BitcoinChainKit
//
//  Created by Jack Pooley on 05/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import PlatformKit

public enum BitcoinChainCoin: String {
    case bitcoin = "BTC"
    case bitcoinCash = "BCH"
    
    public var cryptoCurrency: CryptoCurrency {
        switch self {
        case .bitcoin:
            return .bitcoin
        case .bitcoinCash:
            return .bitcoinCash
        }
    }
    
    public var maximumSupply: BigInt {
        switch self {
        case .bitcoin,
             .bitcoinCash:
            return 2_100_000_000_000_000
        }
    }
    
    public var dust: BigInt {
        switch self {
        case .bitcoin,
             .bitcoinCash:
            return 546
        }
    }
}

public protocol BitcoinChainToken {
    static var coin: BitcoinChainCoin { get }
}

public struct BitcoinToken: BitcoinChainToken {
    public static let coin: BitcoinChainCoin = .bitcoin
}

public struct BitcoinCashToken: BitcoinChainToken {
    public static let coin: BitcoinChainCoin = .bitcoinCash
}
