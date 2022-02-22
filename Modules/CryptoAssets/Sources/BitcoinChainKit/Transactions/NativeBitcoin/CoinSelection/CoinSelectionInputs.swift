// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit

struct CoinSelectionInputs {
    struct Target {
        let value: BigUInt
        let scriptType: UnspentOutput.Script
    }

    let target: Target
    let feePerByte: BigUInt
    let unspentOutputs: [UnspentOutput]
    let sortingStrategy: CoinSortingStrategy
    let changeOutputType: UnspentOutput.Script
}
