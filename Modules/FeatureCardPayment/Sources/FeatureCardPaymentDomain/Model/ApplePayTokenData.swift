// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct ApplePayTokenData: Codable, Equatable {

    public struct Header: Codable, Equatable {

        public let ephemeralPublicKey: String
        public let publicKeyHash: String
        public let transactionId: String

        public init(ephemeralPublicKey: String, publicKeyHash: String, transactionId: String) {
            self.ephemeralPublicKey = ephemeralPublicKey
            self.publicKeyHash = publicKeyHash
            self.transactionId = transactionId
        }
    }

    public let version: String
    public let data: String
    public let signature: String
    public let header: Header

    public init(version: String, data: String, signature: String, header: Header) {
        self.version = version
        self.data = data
        self.signature = signature
        self.header = header
    }
}
