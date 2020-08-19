//
//  ERC20Asset.swift
//  ERC20Kit
//
//  Created by Paulo on 07/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import EthereumKit
import PlatformKit
import RxSwift
import ToolKit

final class ERC20Asset<Token: ERC20Token>: CryptoAsset {

    let asset: CryptoCurrency = Token.assetType

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
                ERC20CryptoAccount<Token>(id: wallet.publicKey)
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
        Single
            .zip(nonCustodialGroup, custodialGroup, interestGroup)
            .map { CryptoAccountNonCustodialGroup(asset: Token.assetType, accounts: $0.0.accounts + $0.1.accounts + $0.2.accounts) }
    }

    private var custodialGroup: Single<AccountGroup> {
        .just(CryptoAccountCustodialGroup(asset: Token.assetType, accounts: [CryptoTradingAccount(asset: Token.assetType)]))
    }

    private var interestGroup: Single<AccountGroup> {
        Single
            .just(CryptoInterestAccount(asset: Token.assetType))
            .map { CryptoAccountCustodialGroup(asset: Token.assetType, accounts: [$0]) }
    }

    private var nonCustodialGroup: Single<AccountGroup> {
        walletAccountBridge.wallets
            .map { wallets -> [SingleAccount] in
                wallets.map { ERC20CryptoAccount<Token>(id: $0.publicKey) }
            }
            .map { accounts -> AccountGroup in
                CryptoAccountNonCustodialGroup(asset: Token.assetType, accounts: accounts)
            }
    }
}
