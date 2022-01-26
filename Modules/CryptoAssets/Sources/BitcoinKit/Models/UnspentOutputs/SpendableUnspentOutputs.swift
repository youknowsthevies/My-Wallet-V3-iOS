// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt

struct SpendableUnspentOutputs: Equatable {

    let absoluteFee: BigUInt
    let amount: BigUInt
    let change: BigUInt
    let spendableOutputs: [UnspentOutput]

    init(
        spendableOutputs: [UnspentOutput],
        absoluteFee: BigUInt,
        amount: BigUInt,
        change: BigUInt
    ) {
        self.spendableOutputs = spendableOutputs
        self.absoluteFee = absoluteFee
        self.amount = amount
        self.change = change
    }
}
