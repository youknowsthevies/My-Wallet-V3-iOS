// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit
import ToolKit

public protocol CoinSelector {
    func select(inputs: CoinSelectionInputs) -> Result<SpendableUnspentOutputs, CoinSelectionError>
    func select(
        all coins: [UnspentOutput],
        feePerByte: BigUInt,
        singleOutputType: BitcoinScriptType
    ) -> Result<SpendableUnspentOutputs, CoinSelectionError>
}

struct CoinSelection: CoinSelector {

    private let calculator: TransactionSizeCalculating

    init(calculator: TransactionSizeCalculating = TransactionSizeCalculator()) {
        self.calculator = calculator
    }

    func select(inputs: CoinSelectionInputs) -> Result<SpendableUnspentOutputs, CoinSelectionError> {
        let outputAmount = inputs.target.value
        let sortingStrategy = inputs.sortingStrategy
        let unspentOutputs = inputs.unspentOutputs
        let feePerByte = inputs.feePerByte.decimal

        guard !unspentOutputs.isEmpty else {
            return .failure(.noCoinsToSelect)
        }

        /// Sort and filter effective coins.
        let effectiveCoins = sortingStrategy
            .sort(coins: unspentOutputs)
            .effective(fee: inputs.feePerByte)

        guard !effectiveCoins.isEmpty else {
            return .failure(.noEffectiveCoins)
        }

        // The selected utxos to be added to the transaction.
        var selected: [UnspentOutput] = []
        // Iteratively, the value of all currently selected coins.
        var accumulatedValue: BigUInt = .zero
        let outputQuantity = TransactionSizeCalculatorQuantities(
            p2pkh: inputs.target.scriptType == .P2PKH ? 1 : 0,
            p2wpkh: inputs.target.scriptType == .P2WPKH ? 1 : 0
        )
        // The base fee is the transactionBytes of just adding the outputs.
        let baseFee: Decimal = calculator.transactionBytes(
            inputs: .zero,
            outputs: outputQuantity
        ) * feePerByte
        // Iteratively, the fee of using all currently selected coins plus the base fee.
        var accumulatedFee = BigUInt(
            (baseFee.roundTo(places: 0, roundingMode: .up) as NSDecimalNumber).stringValue
        )!

        for coin in effectiveCoins {
            // Check if the currently selected coins are enough.
            if accumulatedValue >= outputAmount + accumulatedFee {
                continue
            }

            // Add coin.
            selected.append(coin)
            accumulatedValue += coin.magnitude
            // Add cost of adding coin as input to the accumulated fee.
            let coinFee: Decimal = TransactionCost.PerInput.for(coin.scriptType) * feePerByte
            accumulatedFee += BigUInt(
                (coinFee.roundTo(places: 0, roundingMode: .up) as NSDecimalNumber).stringValue
            )!
        }

        guard !selected.isEmpty else {
            return .failure(.noSelectedCoins)
        }

        guard accumulatedValue >= outputAmount + accumulatedFee else {
            return .failure(.insufficientFunds)
        }

        let remainingValue: BigUInt = accumulatedValue - (outputAmount + accumulatedFee)
        let dustThreshold = calculator.dustThreshold(for: inputs.feePerByte, type: inputs.changeOutputType)
        let remainingValueDecimal = remainingValue.decimal
        let outputs: SpendableUnspentOutputs
        if remainingValueDecimal >= dustThreshold {
            // Change is worth keeping
            let feeForAdditionalChangeOutput = TransactionCost.PerOutput.for(inputs.changeOutputType)
                * feePerByte
            let feeForAdditionalChangeOutputString = (
                feeForAdditionalChangeOutput.roundTo(places: 0, roundingMode: .up) as NSDecimalNumber
            ).stringValue
            outputs = SpendableUnspentOutputs(
                spendableOutputs: selected,
                absoluteFee: accumulatedFee + BigUInt(feeForAdditionalChangeOutputString)!,
                amount: outputAmount,
                change: remainingValue - BigUInt(feeForAdditionalChangeOutputString)!
            )
        } else {
            // Change is not worth keeping
            outputs = SpendableUnspentOutputs(
                spendableOutputs: selected,
                absoluteFee: accumulatedFee + remainingValue,
                amount: outputAmount,
                change: 0
            )
        }
        return .success(outputs)
    }

    func select(
        all coins: [UnspentOutput],
        feePerByte: BigUInt,
        singleOutputType: BitcoinScriptType
    ) -> Result<SpendableUnspentOutputs, CoinSelectionError> {
        let effectiveCoins = coins.effective(fee: feePerByte)
        let effectiveBalance = calculator.effectiveBalance(
            fee: feePerByte,
            inputs: effectiveCoins,
            singleOutputType: singleOutputType
        )
        let balance = effectiveCoins.sum()

        let outputs = SpendableUnspentOutputs(
            spendableOutputs: effectiveCoins,
            absoluteFee: balance - effectiveBalance,
            amount: effectiveBalance,
            change: 0
        )
        return .success(outputs)
    }
}
