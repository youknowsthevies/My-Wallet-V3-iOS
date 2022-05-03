// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct EthereumPushTxResponse: Decodable, Equatable {
    public let txHash: String

    public init(txHash: String) {
        self.txHash = txHash
    }
}

public struct EVMPushTxResponse: Decodable, Equatable {
    public let txId: String?
    public let success: Bool

    public init(txId: String, success: Bool) {
        self.txId = txId
        self.success = success
    }
}
