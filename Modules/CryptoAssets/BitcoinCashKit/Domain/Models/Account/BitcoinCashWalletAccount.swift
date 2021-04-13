//
//  BitcoinCashWalletAccount.swift
//  BitcoinKit
//
//  Created by Alex McGregor on 5/20/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public struct BitcoinCashWalletAccount: WalletAccount, Codable, Hashable {

    public let index: Int

    public let publicKey: String

    public var label: String?

    public var archived: Bool

    public init(index: Int,
                publicKey: String,
                label: String?,
                archived: Bool) {
        self.index = index
        self.publicKey = publicKey
        self.label = label
        self.archived = archived
    }
}

