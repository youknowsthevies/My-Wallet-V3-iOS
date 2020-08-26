//
//  CryptoValue+Bitcoin.swift
//  PlatformKit
//
//  Created by Chris Arriola on 12/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt

// MARK: - Bitcoin

extension CryptoValue {
    
    public static var bitcoinZero: CryptoValue {
        zero(currency: .bitcoin)
    }

    public static func bitcoin(satoshis: BigInt) -> CryptoValue {
        CryptoValue(amount: satoshis, currency: .bitcoin)
    }

    public static func bitcoin(satoshis: Int) -> CryptoValue {
        CryptoValue(amount: BigInt(satoshis), currency: .bitcoin)
    }
}
