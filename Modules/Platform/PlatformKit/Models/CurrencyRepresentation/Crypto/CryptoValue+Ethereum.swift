// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt

// MARK: - Ethereum

extension CryptoValue {

    public static var etherZero: CryptoValue {
        zero(currency: .ethereum)
    }

    public static func ether(gwei: BigInt) -> CryptoValue {
        let wei = gwei * BigInt(1000000000)
        return CryptoValue(amount: wei, currency: .ethereum)
    }
}
