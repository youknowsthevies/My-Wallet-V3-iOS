// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt

public struct SpendableUnspentOutputs: Equatable {

    public let absoluteFee: BigUInt
    public let amount: BigUInt
    public let change: BigUInt
    public let spendableOutputs: [UnspentOutput]

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
