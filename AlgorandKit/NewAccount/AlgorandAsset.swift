//
//  AlgorandAsset.swift
//  AlgorandKit
//
//  Created by Paulo on 14/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class AlgorandAsset: CryptoAsset {

    let asset: CryptoCurrency = .algorand

    var defaultAccount: Single<SingleAccount> {
        .error(CryptoAssetError.noDefaultAccount)
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
        .just(CryptoAccountCustodialGroup(asset: asset, accounts: []))
    }

    private var nonCustodialGroup: Single<AccountGroup> {
        .just(CryptoAccountNonCustodialGroup(asset: asset, accounts: []))
    }
}
