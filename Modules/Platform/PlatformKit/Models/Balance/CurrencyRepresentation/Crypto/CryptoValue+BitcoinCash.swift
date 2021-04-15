//
//  CryptoValue+BitcoinCash.swift
//  PlatformKit
//
//  Created by Chris Arriola on 12/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt

// MARK: - Bitcoin Cash

extension CryptoValue {
    
    public static var bitcoinCashZero: CryptoValue {
        zero(currency: .bitcoinCash)
    }

    public static func bitcoinCash(minorDisplay value: String) -> CryptoValue? {
        create(minorDisplay: value, currency: .bitcoinCash)
    }

    public static func bitcoinCash(satoshis: Int) -> CryptoValue {
        CryptoValue(amount: BigInt(satoshis), currency: .bitcoinCash)
    }
}
