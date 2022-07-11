// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

public struct NativeBitcoinTransactionCandidate {

    public struct MaxValue {

        let available: CryptoValue
        let feeForMaxAvailable: CryptoValue

        public init(
            available: CryptoValue,
            feeForMaxAvailable: CryptoValue
        ) {
            self.available = available
            self.feeForMaxAvailable = feeForMaxAvailable
        }
    }

    /// The array of wallet key pair of the source account
    public let keys: [WalletKeyPair]

    /// The change address for the transaction
    public let changeAddress: String

    /// The wallet address for the destination account
    public let destinationAddress: String

    /// The amount to be sent in crypto value (BTC/BCH)
    public let amount: CryptoValue

    /// The fee for the transaction (BTC/BCH)
    public let fees: CryptoValue

    /// The change for the transaction (BTC/BCH)
    public let change: CryptoValue

    /// The unspent outputs from coin selection result
    public let utxos: [UnspentOutput]

    public let maxValue: MaxValue

    public init(
        keys: [WalletKeyPair],
        changeAddress: String,
        destinationAddress: String,
        amount: CryptoValue,
        fees: CryptoValue,
        change: CryptoValue,
        utxos: [UnspentOutput],
        maxValue: MaxValue
    ) {
        self.amount = amount
        self.change = change
        self.changeAddress = changeAddress
        self.destinationAddress = destinationAddress
        self.fees = fees
        self.keys = keys
        self.maxValue = maxValue
        self.utxos = utxos
    }
}
