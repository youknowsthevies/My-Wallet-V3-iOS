// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import ToolKit

// MARK: - Stellar

extension CryptoValue {

    public static var stellarZero: CryptoValue {
        zero(currency: .stellar)
    }
}
