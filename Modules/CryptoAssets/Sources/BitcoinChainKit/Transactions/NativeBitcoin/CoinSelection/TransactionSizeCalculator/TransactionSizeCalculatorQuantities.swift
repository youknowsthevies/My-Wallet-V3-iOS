// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt

/// An struct that express the quantity of different types of unspent
/// outputs being used.
struct TransactionSizeCalculatorQuantities {

    static let zero = TransactionSizeCalculatorQuantities(p2pkh: 0, p2wpkh: 0)

    let p2pkh: UInt
    let p2wpkh: UInt

    var count: UInt {
        p2pkh + p2wpkh
    }

    var hasWitness: Bool {
        p2wpkh > 0
    }
}
