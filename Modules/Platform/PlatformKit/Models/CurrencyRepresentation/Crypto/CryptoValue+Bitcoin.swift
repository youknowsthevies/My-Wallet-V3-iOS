// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt

// MARK: - Bitcoin

extension CryptoValue {

    public static var bitcoinZero: CryptoValue {
        zero(currency: .bitcoin)
    }
}
