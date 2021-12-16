// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import PlatformKit

public struct BitcoinWalletAccount: Equatable {

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

    public init(index: Int, label: String?, archived: Bool, publicKeys: XPubs) {
        self.index = index
        self.label = label
        self.archived = archived
        self.publicKeys = publicKeys
    }

    public init(index: Int, account: PayloadBitcoinWalletAccountV4) {
        self.index = index
        archived = account.archived
        label = account.label
        let xpubs = account.derivations
            .map { derivation in
                XPub(address: derivation.xpub, derivationType: derivation.type)
            }
        publicKeys = XPubs(xpubs: xpubs)
    }

    public init(index: Int, account: PayloadBitcoinWalletAccountV3) {
        self.index = index
        archived = account.archived
        label = account.label
        publicKeys = XPubs(xpubs: [.init(address: account.xpub, derivationType: .legacy)])
    }
}
