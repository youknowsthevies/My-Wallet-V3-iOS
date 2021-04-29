// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import ToolKit

// MARK: - Stellar

extension CryptoValue {
    
    public static var stellarZero: CryptoValue {
        zero(currency: .stellar)
    }

    public static func stellar(minor value: Int) -> CryptoValue {
        CryptoValue(amount: BigInt(value), currency: .stellar)
    }

    public static func stellar(minor value: String) -> CryptoValue? {
        create(minor: value, currency: .stellar)
    }

    public static func stellar(major value: Int) -> CryptoValue {
        create(major: "\(value)", currency: .stellar)!
    }
    
    public static func stellar(major value: String) -> CryptoValue? {
        create(major: value, currency: .stellar)
    }

    public static func stellar(majorDisplay value: String) -> CryptoValue? {
        create(majorDisplay: value, currency: .stellar)
    }
}
