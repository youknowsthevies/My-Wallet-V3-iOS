// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct NativeSignedBitcoinTransaction {

    /// The encoded signature message
    let encodedMsg: String

    /// The size of the signature message, in bytes
    let msgSize: Int

    /// The transaction hash for the sign transaction
    let txHash: String

    let replayProtectionLockSecret: String?

    public init(
        msgSize: Int,
        txHash: String,
        encodedMsg: String,
        replayProtectionLockSecret: String?
    ) {
        self.msgSize = msgSize
        self.txHash = txHash
        self.encodedMsg = encodedMsg
        self.replayProtectionLockSecret = replayProtectionLockSecret
    }
}
