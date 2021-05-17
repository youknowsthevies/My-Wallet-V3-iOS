// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt

// MARK: - Ethereum

extension CryptoValue {

    public static var etherZero: CryptoValue {
        zero(currency: .ethereum)
    }

    public static func ether(gwei: String) -> CryptoValue? {
        guard let gweiInBigInt = BigInt(gwei) else {
            return nil
        }
        let weiInBigInt = gweiInBigInt * BigInt(1_000_000_000)
        return CryptoValue(amount: weiInBigInt, currency: .ethereum)
    }

    public static func ether(minorDisplay value: String) -> CryptoValue? {
        create(minorDisplay: value, currency: .ethereum)
    }

    public static func ether(minor value: String) -> CryptoValue? {
        create(minor: value, currency: .ethereum)
    }

    public static func ether(major value: String) -> CryptoValue? {
        create(major: value, currency: .ethereum)
    }

    public static func ether(majorDisplay value: String) -> CryptoValue? {
        create(majorDisplay: value, currency: .ethereum)
    }
}
