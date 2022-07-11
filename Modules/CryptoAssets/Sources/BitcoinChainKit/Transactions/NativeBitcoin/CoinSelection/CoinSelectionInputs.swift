// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit

public struct CoinSelectionInputs {

    public struct Target {

        let value: BigUInt
        let scriptType: BitcoinScriptType

        public init(
            value: BigUInt,
            scriptType: BitcoinScriptType
        ) {
            self.value = value
            self.scriptType = scriptType
        }
    }

    public let target: Target
    public let feePerByte: BigUInt
    public let unspentOutputs: [UnspentOutput]
    public let sortingStrategy: CoinSortingStrategy
    public let changeOutputType: BitcoinScriptType

    public init(
        target: CoinSelectionInputs.Target,
        feePerByte: BigUInt,
        unspentOutputs: [UnspentOutput],
        sortingStrategy: CoinSortingStrategy,
        changeOutputType: BitcoinScriptType
    ) {
        self.target = target
        self.feePerByte = feePerByte
        self.unspentOutputs = unspentOutputs
        self.sortingStrategy = sortingStrategy
        self.changeOutputType = changeOutputType
    }
}
