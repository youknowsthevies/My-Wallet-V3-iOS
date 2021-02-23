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
        Single.just(())
            .observeOn(MainScheduler.asyncInstance)
            .flatMap(weak: self) { (self, _) -> Maybe<StellarWalletAccount> in
                self.accountRepository.initializeMetadataMaybe()
            }
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
    private let errorRecorder: ErrorRecording

    init(accountRepository: StellarWalletAccountRepository = resolve(),
         errorRecorder: ErrorRecording = resolve()) {
        self.accountRepository = accountRepository
        self.errorRecorder = errorRecorder
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
        .just(CryptoAccountCustodialGroup(asset: asset, accounts: [CryptoTradingAccount(asset: asset)]))
    }

    private var interestGroup: Single<AccountGroup> {
        let asset = self.asset
        return Single
            .just(CryptoInterestAccount(asset: asset))
            .map { CryptoAccountCustodialGroup(asset: asset, accounts: [$0]) }
    }

    private var nonCustodialGroup: Single<AccountGroup> {
        let asset = self.asset
        return defaultAccount
            .map { account -> AccountGroup in
                CryptoAccountNonCustodialGroup(asset: asset, accounts: [account])
            }
            .recordErrors(on: errorRecorder)
            .catchErrorJustReturn(CryptoAccountNonCustodialGroup(asset: asset, accounts: []))
    }
}
