// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct HDWallet: Equatable {
    let seedHex: String
    let passphrase: String
    let mnemonicVerified: Bool
    let defaultAccountIndex: Int
    let accounts: [Account]

    init(from model: WalletResponseModels.HDWallet) {
        seedHex = model.seedHex
        passphrase = model.passphrase
        mnemonicVerified = model.mnemonicVerified
        defaultAccountIndex = model.defaultAccountIndex

        accounts = model.accounts.enumerated()
            .map { index, account in
                Account(
                    index: index,
                    label: account.label,
                    archived: account.archived,
                    defaultDerivation: DerivationType.create(from: account.defaultDerivation),
                    derivations: account.derivations.map(Derivation.init(from:))
                )
            }
    }
}
