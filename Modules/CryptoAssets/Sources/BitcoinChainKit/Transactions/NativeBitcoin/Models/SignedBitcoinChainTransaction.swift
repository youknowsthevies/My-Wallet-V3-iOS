// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct SignedBitcoinChainTransaction {

    /// The encoded signature message
    public let encodedMsg: String

    /// The size of the signature message, in bytes
    public let msgSize: Int

    /// The transaction hash for the sign transaction
    public let txHash: String

    public init(msgSize: Int, txHash: String, encodedMsg: String = "") {
        self.msgSize = msgSize
        self.txHash = txHash
        self.encodedMsg = encodedMsg
    }
}
