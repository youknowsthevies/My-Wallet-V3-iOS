// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Foundation

// MARK: - Algorand

extension CryptoValue {

    public static var algorandZero: CryptoValue {
        zero(currency: .algorand)
    }

    public static func algorand(minor: BigInt) -> CryptoValue {
        create(minor: minor, currency: .algorand)
    }

    public static func algorand(majorDisplay: String) -> CryptoValue! {
        create(majorDisplay: majorDisplay, currency: .algorand)
    }
}
