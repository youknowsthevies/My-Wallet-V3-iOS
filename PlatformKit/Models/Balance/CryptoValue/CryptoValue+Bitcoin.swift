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

    public static func bitcoinFromSatoshis(bigInt satoshis: BigInt) -> CryptoValue {
        CryptoValue(currencyType: .bitcoin, amount: satoshis)
    }

    public static func bitcoinFromSatoshis(int satoshis: Int) -> CryptoValue {
        CryptoValue(currencyType: .bitcoin, amount: BigInt(satoshis))
    }
}
