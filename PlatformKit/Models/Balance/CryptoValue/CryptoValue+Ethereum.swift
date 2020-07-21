//
//  CryptoValue+Ethereum.swift
//  PlatformKit
//
//  Created by Chris Arriola on 12/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt

// MARK: - Ethereum

extension CryptoValue {
    public static var etherZero: CryptoValue {
        zero(currency: .ethereum)
    }

    public static func etherFromWei(string wei: String) -> CryptoValue? {
        etherFromMinor(string: wei)
    }

    public static func etherFromGwei(string gwei: String) -> CryptoValue? {
        guard let gweiInBigInt = BigInt(gwei) else {
            return nil
        }
        let weiInBigInt = gweiInBigInt * BigInt(1_000_000_000)
        return CryptoValue(currencyType: .ethereum, amount: weiInBigInt)
    }

    public static func etherFromMinor(string ether: String) -> CryptoValue? {
        createFromMinorValue(ether, assetType: .ethereum)
    }

    public static func etherFromMajor(string ether: String, locale: Locale = Locale.current) -> CryptoValue? {
        createFromMajorValue(string: ether, assetType: .ethereum, locale: locale)
    }
}
