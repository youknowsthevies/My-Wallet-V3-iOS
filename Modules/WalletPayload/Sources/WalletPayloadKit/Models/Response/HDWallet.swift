// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct HDWallet: Equatable, Codable {
    let seedHex: String
    let passphrase: String
    let mnemonicVerified: Bool
    let defaultAccountIndex: Int
    let accounts: [Account]

    enum CodingKeys: String, CodingKey {
        case seedHex = "seed_hex"
        case passphrase
        case mnemonicVerified = "mnemonic_verified"
        case defaultAccountIndex = "default_account_idx"
        case accounts
    }

    init(
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        seedHex = try container.decode(String.self, forKey: .seedHex)
        passphrase = try container.decode(String.self, forKey: .passphrase)
        mnemonicVerified = try container.decode(Bool.self, forKey: .mnemonicVerified)
        defaultAccountIndex = try container.decode(Int.self, forKey: .defaultAccountIndex)

        // attempt to decode version4 first and then version3, if both fail then an error will be thrown
        do {
            let accountsVersion4 = try container.decode([AccountWrapper.Version4].self, forKey: .accounts)
            accounts = try decodeAccounts(
                using: accountWrapperDecodingStrategy(version4:),
                value: accountsVersion4
            )
            .get()
        } catch is DecodingError {
            let accountsVersion3 = try container.decode([AccountWrapper.Version3].self, forKey: .accounts)
            accounts = try decodeAccounts(
                using: accountWrapperDecodingStrategy(version3:),
                value: accountsVersion3
            )
            .get()
        }
    }
}
