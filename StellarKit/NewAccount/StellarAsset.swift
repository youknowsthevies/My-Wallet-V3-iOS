//
//  StellarAsset.swift
//  StellarKit
//
//  Created by Paulo on 10/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class StellarAsset: CryptoAsset {

    let asset: CryptoCurrency = .stellar

    var defaultAccount: Single<SingleAccount> {
        self.accountRepository
            .initializeMetadataMaybe()
            .asObservable()
            .first()
            .map { account -> StellarWalletAccount in
                guard let account = account else {
                    throw StellarAccountError.noDefaultAccount
                }
                return account
            }
            .map { account -> SingleAccount in
                StellarCryptoAccount(id: account.publicKey, label: account.label)
            }
    }

    private let accountRepository: StellarWalletAccountRepository

    init(accountRepository: StellarWalletAccountRepository = resolve()) {
        self.accountRepository = accountRepository
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
            .zip(nonCustodialGroup, custodialGroup, interestGroup)
            .map { CryptoAccountNonCustodialGroup(asset: asset, accounts: $0.0.accounts + $0.1.accounts + $0.2.accounts) }
    }

    private var custodialGroup: Single<AccountGroup> {
         .just(CryptoAccountCustodialGroup(asset: asset, accounts: []))
    }

    private var interestGroup: Single<AccountGroup> {
        Single
            .just(CryptoInterestAccount(asset: .stellar))
            .map { CryptoAccountCustodialGroup(asset: .stellar, accounts: [$0]) }
    }

    private var nonCustodialGroup: Single<AccountGroup> {
        defaultAccount
            .map { account -> AccountGroup in
                CryptoAccountNonCustodialGroup(asset: .stellar, accounts: [account])
            }
    }
}
