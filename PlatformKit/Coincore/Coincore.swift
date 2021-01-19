//
//  Coincore.swift
//  PlatformKit
//
//  Created by Paulo on 05/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift
import ToolKit

public final class Coincore {
    
    // MARK: - Public Properties

    public var allAccounts: Single<AccountGroup> {
        reactiveWallet.waitUntilInitializedSingle
            .flatMap(weak: self) { (self, _) in
                Single.zip(
                    self.allAssets.map { asset in asset.accountGroup(filter: .all) }
                )
            }
            .map { accountGroups -> [SingleAccount] in
                accountGroups.map { $0.accounts }.reduce([SingleAccount](), +)
            }
            .map { accounts -> AccountGroup in
                AllAccountsGroup(accounts: accounts)
            }
    }
    
    // MARK: - Private Properties

    private var allAssets: [Asset] {
        [fiatAsset] + sortedCryptoAssets
    }
    
    private var sortedCryptoAssets: [CryptoAsset] {
        cryptoAssets.sorted(by: { $0.key < $1.key }).map { $0.value }
    }
    
    private let cryptoAssets: [CryptoCurrency: CryptoAsset]
    private let fiatAsset: FiatAsset
    private let reactiveWallet: ReactiveWalletAPI
    
    // MARK: - Setup

    init(cryptoAssets: [CryptoCurrency: CryptoAsset],
         fiatAsset: FiatAsset = FiatAsset(),
         reactiveWallet: ReactiveWalletAPI = resolve()) {
        self.cryptoAssets = cryptoAssets
        self.fiatAsset = fiatAsset
        self.reactiveWallet = reactiveWallet
    }

    public func getTransactionTargets(
        sourceAccount: CryptoAccount,
        action: AssetAction
    ) -> Single<[SingleAccount]> {
        switch action {
        case .swap:
            return allAccounts
                .map(\.accounts)
                .map(weak: self) { (self, accounts) -> [SingleAccount] in
                    accounts.filter { destinationAccount -> Bool in
                        self.getActionFilter(
                            sourceAccount: sourceAccount,
                            destinationAccount: destinationAccount,
                            action: action
                        )
                    }
                }
        case .deposit,
             .receive,
             .sell,
             .send,
             .viewActivity,
             .withdraw:
            unimplemented()
        }
    }

    private func getActionFilter(sourceAccount: CryptoAccount, destinationAccount: SingleAccount, action: AssetAction) -> Bool {
        switch action {
        case .sell:
            return destinationAccount is FiatAccount
        case .swap:
            return destinationAccount is CryptoAccount
                && destinationAccount.currencyType != sourceAccount.currencyType
                && !(destinationAccount is FiatAccount)
                && !(destinationAccount is CryptoInterestAccount)
                && (sourceAccount is TradingAccount ? destinationAccount is TradingAccount : true)
        case .send:
            return !(destinationAccount is FiatAccount)
        case .deposit,
             .receive,
             .viewActivity,
             .withdraw:
            return false
        }
    }
}
