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
        walletAccountBridge.wallets
            .map { $0.first }
            .map { wallet -> EthereumWalletAccount in
                guard let wallet = wallet else {
                    throw CryptoAssetError.noDefaultAccount
                }
                return wallet
            }
            .map { wallet -> SingleAccount in
                EthereumCryptoAccount(id: wallet.publicKey, label: wallet.label)
            }
    }

    private let walletAccountBridge: EthereumWalletAccountBridgeAPI

    init(walletAccountBridge: EthereumWalletAccountBridgeAPI = resolve()) {
        self.walletAccountBridge = walletAccountBridge
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
        Single
            .just(CryptoInterestAccount(asset: .ethereum))
            .map { CryptoAccountCustodialGroup(asset: .ethereum, accounts: [$0]) }
    }

    private var nonCustodialGroup: Single<AccountGroup> {
        walletAccountBridge.wallets
            .map { wallets -> [SingleAccount] in
                wallets.map { EthereumCryptoAccount(id: $0.publicKey, label: $0.label) }
            }
            .map { accounts -> AccountGroup in
                CryptoAccountNonCustodialGroup(asset: .ethereum, accounts: accounts)
            }
    }
}
