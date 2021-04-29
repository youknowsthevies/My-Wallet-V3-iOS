// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import PlatformKit

public struct BitcoinWalletAccount {

    // MARK: Public Properties

    public let archived: Bool
    public let index: Int
    public let label: String?
    public let publicKeys: XPubs

    // MARK: Internal Properties

    var isActive: Bool {
        !archived
    }

    // MARK: Initializers

    public init(index: Int, account: PayloadBitcoinWalletAccountV4) {
        self.index = index
        self.archived = account.archived
        self.label = account.label
        let xpubs = account.derivations
            .map { derivation in
                XPub(address: derivation.xpub, derivationType: derivation.type)
            }
        self.publicKeys = XPubs(xpubs: xpubs)
    }

    public init(index: Int, account: PayloadBitcoinWalletAccountV3) {
        self.index = index
        self.archived = account.archived
        self.label = account.label
        self.publicKeys = XPubs(xpubs: [.init(address: account.xpub, derivationType: .legacy)])
    }
}
