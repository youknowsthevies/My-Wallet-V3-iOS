//
//  BitcoinCashWallet.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/20/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinKit
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
    
    // MARK: - Injected
    
    private let reactiveWallet: ReactiveWalletAPI
    private let wallet: Wallet
    
    init(reactiveWallet: ReactiveWalletAPI = WalletManager.shared.reactiveWallet,
         wallet: Wallet = WalletManager.shared.wallet) {
        self.reactiveWallet = reactiveWallet
        self.wallet = wallet
    }
    
    // MARK: - Private
    
    private func fetchDefaultWallet() -> Single<BitcoinCashWalletAccount> {
        Single<BitcoinCashWalletAccount>.create(weak: self) { (self, observer) -> Disposable in
            guard let payload = self.wallet.fetchDefaultBCHAccount() else {
                observer(.error(WalletError.unknown))
                return Disposables.create()
            }
            guard
                let label = payload["label"] as? String,
                let index = payload["index"] as? NSNumber,
                let xpub = payload["xpub"] as? String
                else {
                    observer(.error(WalletError.unknown))
                    return Disposables.create()
                }
            
            let account = BitcoinCashWalletAccount(
                index: index.intValue,
                publicKey: xpub,
                label: label,
                archived: false
            )
            observer(.success(account))
            return Disposables.create()
        }
    }
}
