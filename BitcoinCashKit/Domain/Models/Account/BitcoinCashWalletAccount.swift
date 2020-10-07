//
//  BitcoinCashWalletAccount.swift
//  BitcoinCashKit
//
//  Created by Jack Pooley on 05/10/2020.
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
