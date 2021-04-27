//
//  BitcoinCashWalletAccount.swift
//  BitcoinKit
//
//  Created by Alex McGregor on 5/20/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinChainKit
import PlatformKit

public struct BitcoinCashWalletAccount {

    public let archived: Bool
    public let index: Int
    public let label: String?
    public let publicKey: XPub

    public init(index: Int,
                publicKey: String,
                label: String?,
                derivationType: DerivationType,
                archived: Bool) {
        self.archived = archived
        self.index = index
        self.label = label
        self.publicKey = XPub(address: publicKey, derivationType: derivationType)
    }
}
