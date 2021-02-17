//
//  EthereumAsset.swift
//  EthereumKit
//
//  Created by Paulo on 03/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class EthereumAsset: CryptoAsset {

    let asset: CryptoCurrency = .ethereum

    var defaultAccount: Single<SingleAccount> {
        repository.defaultAccount
            .map { walletAccount -> SingleAccount in
                EthereumCryptoAccount(
                    id: walletAccount.publicKey,
                    label: walletAccount.label
                )
            }
    }
    
    private let repository: EthereumWalletAccountRepositoryAPI
    private let errorRecorder: ErrorRecording

    init(repository: EthereumWalletAccountRepositoryAPI = resolve(),
         errorRecorder: ErrorRecording = resolve()) {
        self.repository = repository
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
        return Single.zip(nonCustodialGroup, custodialGroup, interestGroup)
            .map { (nonCustodialGroup, custodialGroup, interestGroup) -> [SingleAccount] in
                nonCustodialGroup.accounts + custodialGroup.accounts + interestGroup.accounts
            }
            .map { accounts -> AccountGroup in
                CryptoAccountNonCustodialGroup(asset: asset, accounts: accounts)
            }
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
                CryptoAccountNonCustodialGroup(asset: asset, accounts: [ account ])
            }
            .recordErrors(on: errorRecorder)
            .catchErrorJustReturn(CryptoAccountNonCustodialGroup(asset: asset, accounts: []))
    }
}
