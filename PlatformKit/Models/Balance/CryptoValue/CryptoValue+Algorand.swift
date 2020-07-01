//
//  CryptoValue+Algorand.swift
//  PlatformKit
//
//  Created by Paulo on 09/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import Foundation

// MARK: - Algorand

extension CryptoValue {
    public static var algorandZero: CryptoValue {
        zero(assetType: .algorand)
    }

    public static func algorand(minor: BigInt) -> CryptoValue {
        .createFromMinorValue(minor, assetType: .algorand)
    }

    public static func algorand(major: String) -> CryptoValue! {
        .createFromMajorValue(string: major, assetType: .algorand)
    }
}
