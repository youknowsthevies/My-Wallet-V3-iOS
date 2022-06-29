// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct PayloadBitcoinWalletAccountV3: Codable {

    public struct Cache: Codable {
        public let receiveAccount: String
        public let changeAccount: String
    }

    public struct Label: Codable {
        public let index: Int
        public let label: String
    }

    public let label: String
    public let archived: Bool
    public let xpriv: String
    public let xpub: String
    public let address_labels: [Label]?
    public let cache: Cache
}
