// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct NativeBitcoinChainTransactionCandidate<Token: BitcoinChainToken> {

    /// The array of wallet key pair of the source account
    public let source: [WalletKeyPair]

    /// The wallet address for the destination account
    public let destinationAddress: String

    /// The amount to be sent in crypto value (BTC/BCH)
    public let amount: CryptoValue

    /// The fee for the transaction (BTC/BCH)
    public let fees: CryptoValue

    /// The unspent outputs from coin selection result
    public let utxos: [UnspentOutput]

    public init(
        source: [WalletKeyPair],
        destinationAddress: String,
        amount: CryptoValue,
        fees: CryptoValue,
        utxos: [UnspentOutput]
    ) {
        self.source = source
        self.destinationAddress = destinationAddress
        self.amount = amount
        self.fees = fees
        self.utxos = utxos
    }
}

public struct NativeBitcoinChainSweepCandidate<Token: BitcoinChainToken> {

    /// The total available amount can be sent (sweeping a wallet)
    public let sweepAmount: CryptoValue

    /// The fee to sweep a wallet (the fee needed to send the sweep amount)
    public let sweepFee: CryptoValue

    public init(
        sweepAmount: CryptoValue,
        sweepFee: CryptoValue
    ) {
        self.sweepAmount = sweepAmount
        self.sweepFee = sweepFee
    }
}
