//
//  BitcoinCashWalletAccount.swift
//  BitcoinKit
//
//  Created by Alex McGregor on 5/20/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinChainKit
import PlatformKit

public struct BitcoinCashWalletAccount: WalletAccount, Codable, Hashable {

    public let archived: Bool
    public let index: Int
    public let label: String?
    public let publicKey: String
    public let derivationType: DerivationType

    public init(index: Int,
                publicKey: String,
                label: String?,
                derivationType: DerivationType,
                archived: Bool) {
        self.archived = archived
        self.index = index
        self.label = label
        self.publicKey = publicKey
        self.derivationType = derivationType
    }
}
