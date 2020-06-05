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
        zero(assetType: .bitcoinCash)
    }

    public static func bitcoinCashFromSatoshis(string satoshis: String) -> CryptoValue? {
        createFromMinorValue(satoshis, assetType: .bitcoinCash)
    }

    public static func bitcoinCashFromSatoshis(int satoshis: Int) -> CryptoValue {
        CryptoValue(currencyType: .bitcoinCash, amount: BigInt(satoshis))
    }
}
