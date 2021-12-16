// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit

/// An entry model that contains information on constructing BitcoinCash wallet account
public struct BitcoinEntry: Equatable {
    public struct XPub: Equatable {
        public let address: String
        public let type: DerivationType

        init(from derivation: Derivation) {
            address = derivation.xpub
            type = derivation.type
        }
    }

    public struct Account: Equatable {
        public let index: Int
        public let label: String
        public let archived: Bool
        public let xpubs: [XPub]
    }

    private let payload: BitcoinEntryPayload

    public let defaultAccountIndex: Int

    public let accounts: [BitcoinEntry.Account]

    init(payload: BitcoinEntryPayload, wallet: Wallet) {
        self.payload = payload
        defaultAccountIndex = wallet.defaultHDWallet?.defaultAccountIndex ?? 0
        let hdWalletAccounts = wallet.defaultHDWallet?.accounts ?? []
        accounts = hdWalletAccounts
            .enumerated()
            .map { index, account in
                Account(
                    index: index,
                    label: account.label,
                    archived: account.archived,
                    xpubs: account.derivations.map(XPub.init(from:))
                )
            }
    }
}
