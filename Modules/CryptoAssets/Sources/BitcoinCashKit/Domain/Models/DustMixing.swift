// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import MoneyKit

public struct DustMixing {

    /// Unspent transaction.
    public let unspentOutput: UnspentOutput
    /// Amount to be received at the other end.
    public let amount: UInt64
    /// OutputScript to send the amount
    public let outputScript: String
    /// OutputScript to send the amount
    public let lockSecret: String

    init(response: BchDustResponse) {
        let unspentOutput = UnspentOutput(
            confirmations: UInt(response.confirmations),
            hash: response.tx_hash,
            hashBigEndian: response.tx_hash_big_endian,
            outputIndex: response.tx_output_n,
            script: response.script,
            transactionIndex: response.tx_index,
            value: CryptoValue.create(minor: response.value, currency: .bitcoinCash),
            xpub: UnspentOutput.XPub(m: "", path: "")
        )
        self.init(
            unspentOutput: unspentOutput,
            amount: 546,
            outputScript: response.output_script,
            lockSecret: response.lock_secret
        )
    }

    init(
        unspentOutput: UnspentOutput,
        amount: UInt64,
        outputScript: String,
        lockSecret: String
    ) {
        self.unspentOutput = unspentOutput
        self.amount = amount
        self.outputScript = outputScript
        self.lockSecret = lockSecret
    }
}
