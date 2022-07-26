// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct PayloadBitcoinWalletAccountV4: Decodable {

    public struct Derivation: Decodable {

        public struct Cache: Decodable {
            public let receiveAccount: String
            public let changeAccount: String
        }

        public struct Label: Decodable {
            public let index: Int
            public let label: String
        }

        public let address_labels: [Label]?
        public let cache: Cache
        public let purpose: Int
        public let type: DerivationType
        public let xpub: String
        public let xpriv: String
    }

    public let label: String
    public let archived: Bool
    public let default_derivation: String
    public let derivations: [Derivation]
}
