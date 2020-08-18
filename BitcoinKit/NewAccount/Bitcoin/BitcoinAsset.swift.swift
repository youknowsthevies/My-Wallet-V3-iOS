//
//  BitcoinAsset.swift.swift
//  BitcoinKit
//
//  Created by Paulo on 11/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class BitcoinAsset: CryptoAsset {

    let asset: CryptoCurrency = .bitcoin

    var defaultAccount: Single<SingleAccount> {
        repository.defaultAccount
            .map { BitcoinCryptoAccount(id: $0.publicKey, label: $0.label, isDefault: true) }
    }

    private let repository: BitcoinWalletAccountRepository

    init(repository: BitcoinWalletAccountRepository = resolve()) {
        self.repository = repository
    }

    func accountGroup(filter: AssetFilter) -> Single<AccountGroup> {
        switch filter {
        case .all:
            return allAccountsGroup
        case .custodial:
            return custodialGroup
        case .interest:
            return interestGroup
        case .nonCustodial:
            return nonCustodialGroup
        }
    }

    // MARK: - Helpers

    private var allAccountsGroup: Single<AccountGroup> {
        let asset = self.asset
        return Single
            .zip(custodialGroup, interestGroup, nonCustodialGroup)
            .map { CryptoAccountNonCustodialGroup(asset: asset, accounts: $0.0.accounts + $0.1.accounts + $0.2.accounts) }
    }

    private var custodialGroup: Single<AccountGroup> {
         .just(CryptoAccountCustodialGroup(asset: asset, accounts: []))
    }

    private var interestGroup: Single<AccountGroup> {
        let asset = self.asset
        return Single
            .just(CryptoInterestAccount(asset: asset))
            .map { CryptoAccountCustodialGroup(asset: asset, accounts: [$0]) }
    }

    private var nonCustodialGroup: Single<AccountGroup> {
        let asset = self.asset
        return repository
            .accounts
            .flatMap(weak: self) { (self, accounts) -> Single<(defaultAccount: BitcoinWalletAccount, accounts: [BitcoinWalletAccount])> in
                self.repository.defaultAccount
                    .map { ($0, accounts) }
            }
            .map { (defaultAccount, accounts) -> [SingleAccount] in
                accounts.map {
                    BitcoinCryptoAccount(
                        id: $0.publicKey,
                        label: $0.label,
                        isDefault: $0.publicKey == defaultAccount.publicKey
                    )
                }
            }
            .map { accounts -> AccountGroup in
                CryptoAccountNonCustodialGroup(asset: asset, accounts: accounts)
            }
    }
}
