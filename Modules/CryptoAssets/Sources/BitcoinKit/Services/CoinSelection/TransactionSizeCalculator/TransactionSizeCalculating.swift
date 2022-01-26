// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Foundation

protocol TransactionSizeCalculating {
    func transactionBytes(
        inputs: TransactionSizeCalculatorQuantities,
        outputs: TransactionSizeCalculatorQuantities
    ) -> Decimal
    func dustThreshold(
        for feePerByte: BigUInt,
        type: UnspentOutput.Script
    ) -> Decimal
    func effectiveBalance(
        for feePerByte: BigUInt,
        inputs: [UnspentOutput],
        outputs: TransactionSizeCalculatorQuantities
    ) -> BigUInt
}

extension TransactionSizeCalculating {

    func transactionBytes(
        inputs: [UnspentOutput],
        outputs: [UnspentOutput]
    ) -> Decimal {
        transactionBytes(
            inputs: quantify(unspentOutputs: inputs),
            outputs: quantify(unspentOutputs: outputs)
        )
    }

    /// Calculates how many of each UnspentOutput type is in the provided array.
    func quantify(
        unspentOutputs: [UnspentOutput]
    ) -> TransactionSizeCalculatorQuantities {
        let scriptTypes = unspentOutputs.map(\.scriptType)
        return TransactionSizeCalculatorQuantities(
            p2pkh: UInt(scriptTypes.filter { $0 == .P2PKH }.count),
            p2wpkh: UInt(scriptTypes.filter { $0 == .P2WPKH }.count)
        )
    }

    func effectiveBalance(
        fee feePerByte: BigUInt,
        inputs: [UnspentOutput],
        outputs: [UnspentOutput]
    ) -> BigUInt {
        effectiveBalance(
            for: feePerByte,
            inputs: inputs,
            outputs: quantify(unspentOutputs: outputs)
        )
    }

    func effectiveBalance(
        fee feePerByte: BigUInt,
        inputs: [UnspentOutput],
        singleOutputType: UnspentOutput.Script
    ) -> BigUInt {
        let outputs: TransactionSizeCalculatorQuantities
        switch singleOutputType {
        case .P2PKH:
            outputs = .init(p2pkh: 1, p2wpkh: 0)
        case .P2WPKH:
            outputs = .init(p2pkh: 0, p2wpkh: 1)
        case .P2SH:
            return 0
        case .P2WSH:
            return 0
        }
        return effectiveBalance(for: feePerByte, inputs: inputs, outputs: outputs)
    }
}
