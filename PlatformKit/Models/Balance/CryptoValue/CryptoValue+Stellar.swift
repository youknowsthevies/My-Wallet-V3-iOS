//
//  CryptoValue+Stellar.swift
//  PlatformKit
//
//  Created by Chris Arriola on 12/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt

// MARK: - Stellar

extension CryptoValue {
    public static var lumensZero: CryptoValue {
        zero(currency: .stellar)
    }

    public static func lumensFromStroops(int stroops: Int) -> CryptoValue {
        CryptoValue(currencyType: .stellar, amount: BigInt(stroops))
    }

    public static func lumensFromStroops(string stroops: String) -> CryptoValue? {
        guard let stroopsInBigInt = BigInt(stroops) else {
            return nil
        }
        return CryptoValue(currencyType: .stellar, amount: stroopsInBigInt)
    }

    public static func lumensFromMajor(int lumens: Int) -> CryptoValue {
        createFromMajorValue(string: "\(lumens)", assetType: .stellar)!
    }

    public static func lumensFromMajor(string lumens: String) -> CryptoValue? {
        createFromMajorValue(string: lumens, assetType: .stellar)
    }
}
