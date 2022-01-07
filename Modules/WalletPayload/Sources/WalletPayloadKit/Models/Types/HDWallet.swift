// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public final class HDWallet: Equatable {
    var seedHex: String
    var passphrase: String
    var mnemonicVerified: Bool
    var defaultAccountIndex: Int
    var accounts: [Account]

    public init(
        seedHex: String,
        passphrase: String,
        mnemonicVerified: Bool,
        defaultAccountIndex: Int,
        accounts: [Account]
    ) {
        self.seedHex = seedHex
        self.passphrase = passphrase
        self.mnemonicVerified = mnemonicVerified
        self.defaultAccountIndex = defaultAccountIndex
        self.accounts = accounts
    }
}

extension HDWallet {
    public static func == (lhs: HDWallet, rhs: HDWallet) -> Bool {
        lhs.seedHex == rhs.seedHex
            && lhs.passphrase == rhs.passphrase
            && lhs.mnemonicVerified == rhs.mnemonicVerified
            && lhs.defaultAccountIndex == rhs.defaultAccountIndex
            && lhs.accounts == rhs.accounts
    }
}
