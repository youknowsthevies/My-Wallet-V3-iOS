//
//  BitcoinCashWallet.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/20/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinKit
import DIKit
import PlatformKit
import RxRelay
import RxSwift

final class BitcoinCashWallet: BitcoinCashWalletBridgeAPI {

    // MARK: - BitcoinCashWalletBridgeAPI
    
    var defaultWallet: Single<BitcoinCashWalletAccount> {
        reactiveWallet
            .waitUntilInitializedSingle
            .flatMap(weak: self) { (self, _) -> Single<BitcoinCashWalletAccount> in
                self.fetchDefaultWallet()
            }
    }

    var wallets: Single<[BitcoinCashWalletAccount]> {
        reactiveWallet
            .waitUntilInitializedSingle
            .flatMap(weak: self) { (self, _) -> Single<[BitcoinCashWalletAccount]> in
                self.fetchAllWallets()
            }
    }

    // MARK: - Injected
    
    private let reactiveWallet: ReactiveWalletAPI
    private let wallet: LegacyBitcoinCashWalletProtocol
    
    init(reactiveWallet: ReactiveWalletAPI = resolve(),
         walletManager: WalletManager = resolve()) {
        self.reactiveWallet = reactiveWallet
        self.wallet = walletManager.wallet
    }
    
    // MARK: - Private

    private func fetchAllWallets() -> Single<[BitcoinCashWalletAccount]> {
        Single<[BitcoinCashWalletAccount]>.create(weak: self) { (self, observer) -> Disposable in
            guard let payload: [[String: Any]] = self.wallet.bitcoinCashWallets() else {
                observer(.error(WalletError.unknown))
                return Disposables.create()
            }
            let accounts: [BitcoinCashWalletAccount] = payload.compactMap { data in
                guard
                    let label = data["label"] as? String,
                    let index = data["index"] as? NSNumber,
                    let xpub = data["xpub"] as? String,
                    let archived = data["archived"] as? Bool
                    else {
                        return nil
                }

                return BitcoinCashWalletAccount(
                    index: index.intValue,
                    publicKey: xpub,
                    label: label,
                    archived: archived
                )
            }
            observer(.success(accounts))
            return Disposables.create()
        }
    }
    
    private func fetchDefaultWallet() -> Single<BitcoinCashWalletAccount> {
        Single<BitcoinCashWalletAccount>.create(weak: self) { (self, observer) -> Disposable in
            guard let payload = self.wallet.bitcoinCashDefaultWallet() else {
                observer(.error(WalletError.unknown))
                return Disposables.create()
            }
            guard
                let label = payload["label"] as? String,
                let index = payload["index"] as? NSNumber,
                let xpub = payload["xpub"] as? String,
                let archived = payload["archived"] as? Bool
                else {
                    observer(.error(WalletError.unknown))
                    return Disposables.create()
                }
            
            let account = BitcoinCashWalletAccount(
                index: index.intValue,
                publicKey: xpub,
                label: label,
                archived: archived
            )
            observer(.success(account))
            return Disposables.create()
        }
    }
}
