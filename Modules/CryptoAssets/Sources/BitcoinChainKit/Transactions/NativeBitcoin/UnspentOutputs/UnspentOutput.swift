// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
import PlatformKit
import ToolKit
import WalletCore

public struct UnspentOutput: Equatable {

    struct XPub: Equatable {
        let m: String
        let path: String
    }

    var magnitude: BigUInt {
        value.amount.magnitude
    }

    let hash: String

    let script: String

    let value: CryptoValue

    let confirmations: UInt

    let transactionIndex: Int

    let xpub: XPub

    init(
        hash: String,
        script: String,
        value: CryptoValue,
        confirmations: UInt,
        transactionIndex: Int,
        xpub: XPub
    ) {
        self.hash = hash
        self.script = script
        self.value = value
        self.confirmations = confirmations
        self.transactionIndex = transactionIndex
        self.xpub = xpub
    }
}

extension UnspentOutput {
    enum Script: String {
        case P2PKH
        case P2SH
        case P2WPKH
        case P2WSH
    }

    var scriptType: Script {
        guard let hexString = Data(hexString: script) else {
            fatalError("Misconfigured")
        }
        let script = BitcoinScript(data: hexString)
        if script.isPayToWitnessPublicKeyHash {
            return .P2WPKH
        } else if script.isPayToWitnessScriptHash {
            return .P2WSH
        } else if script.isPayToScriptHash {
            return .P2SH
        } else if script.matchPayToPubkeyHash() != nil {
            return .P2PKH
        }
        fatalError("Misconfigured")
    }
}

extension UnspentOutput {
    init(response: UnspentOutputResponse) {
        let value = CryptoValue.create(minor: response.value, currency: .bitcoin)
        hash = response.tx_hash
        script = response.script
        self.value = value
        confirmations = response.confirmations
        transactionIndex = response.tx_index
        xpub = XPub(responseXPub: response.xpub)
    }
}

extension UnspentOutput.XPub {
    init(responseXPub: UnspentOutputResponse.XPub) {
        m = responseXPub.m
        path = responseXPub.path
    }
}

extension UnspentOutput {

    /// Calculate the effective value of the coin, that is the value minus the fee that takes to add this coin as input.
    /// ceil(value - cost(type) * fee)
    func effectiveValue(fee feePerByte: BigUInt) -> BigUInt {
        let feePerByte = feePerByte.decimal
        let cost = feePerByte * TransactionCost.PerInput.for(scriptType)
        let value = magnitude.decimal
        let effectiveValue = (value - cost).roundTo(places: 0, roundingMode: .up)
        guard effectiveValue > 0 else {
            return .zero
        }
        return BigUInt((effectiveValue as NSDecimalNumber).stringValue)!
    }
}

extension Array where Element == UnspentOutput {
    func sum() -> BigUInt {
        guard !isEmpty else {
            return BigUInt.zero
        }
        return map(\.magnitude)
            .reduce(BigUInt.zero) { value, acc -> BigUInt in
                value + acc
            }
    }

    func effective(fee feePerByte: BigUInt) -> [UnspentOutput] {
        filter { $0.effectiveValue(fee: feePerByte) > BigUInt.zero }
    }
}
