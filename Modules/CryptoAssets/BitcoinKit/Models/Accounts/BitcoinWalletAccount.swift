//
//  BitcoinWalletAccount.swift
//  BitcoinKit
//
//  Created by Jack on 05/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinChainKit
import PlatformKit

public struct BitcoinWalletAccount: WalletAccount, Codable, Hashable {

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
