//
//  Coincore.swift
//  PlatformKit
//
//  Created by Paulo on 05/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

final public class Coincore {

    private let assetMap: [CryptoCurrency: CryptoAsset]

    init(assetMap: [CryptoCurrency: CryptoAsset]) {
        self.assetMap = assetMap
    }

    public var allAccounts: Single<AccountGroup> {
        Single
            .zip(
                assetMap
                    .sorted(by: { $0.key < $1.key })
                    .map { $0.value }
                    .map { asset in asset.accountGroup(filter: .all) }
            )
            .map { accountGroups -> [SingleAccount] in
                accountGroups.map { $0.accounts }.reduce([SingleAccount](), +)
            }
            .map { accounts -> AccountGroup in
                AllAccountsGroup(accounts: accounts)
            }
    }
}
