//
//  Coincore.swift
//  PlatformKit
//
//  Created by Paulo on 05/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public final class Coincore {

    // MARK: Private Properties

    private let cryptoAssets: [CryptoCurrency: CryptoAsset]
    private let fiatAsset: FiatAsset
    private var allAssets: [Asset] {
        [fiatAsset] + sortedCryptoAssets
    }
    private var sortedCryptoAssets: [CryptoAsset] {
        cryptoAssets.sorted(by: { $0.key < $1.key }).map { $0.value }
    }

    // MARK: Public Properties

    public var allAccounts: Single<AccountGroup> {
        Single
            .zip(
                allAssets.map { asset in asset.accountGroup(filter: .all) }
            )
            .map { accountGroups -> [SingleAccount] in
                accountGroups.map { $0.accounts }.reduce([SingleAccount](), +)
            }
            .map { accounts -> AccountGroup in
                AllAccountsGroup(accounts: accounts)
            }
    }

    // MARK: Setup

    init(cryptoAssets: [CryptoCurrency: CryptoAsset],
         fiatAsset: FiatAsset = FiatAsset()) {
        self.cryptoAssets = cryptoAssets
        self.fiatAsset = fiatAsset
    }
}
