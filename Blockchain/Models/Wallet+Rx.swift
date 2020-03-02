//
//  Wallet+Rx.swift
//  Blockchain
//
//  Created by Daniel Huri on 05/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

/// An extension to `Wallet` which makes wallet fuctionality Rx friendly.
final class ReactiveWallet: ReactiveWalletAPI {
            
    var waitUntilInitialized: Observable<Void> {
        return initializationState
            .asObservable()
            .map { state -> Void in
                if state == .uninitialized {
                    throw WalletSetup.StateError.walletUnitinialized
                }
                return ()
            }
            .retry(
                .delayed(maxCount: .max, time: 0.5),
                scheduler: MainScheduler.instance,
                shouldRetry: { error -> Bool in
                    return true
                }
            )
    }
    
    var waitUntilInitializedSingle: Single<Void> {
        return waitUntilInitialized.take(1).asSingle()
    }
    
    /// A `Single` that streams a boolean element indicating
    /// whether the wallet is initialized
    var initializationState: Single<WalletSetup.State> {
        return Single
            .create(weak: self) { (self, observer) -> Disposable in
                if self.wallet.isInitialized() {
                    observer(.success(.initialized))
                } else {
                    observer(.success(.uninitialized))
                }
                return Disposables.create()
            }
            .subscribeOn(MainScheduler.instance)
    }
    
    private let wallet: Wallet
    
    init(wallet: Wallet = WalletManager.shared.wallet) {
        self.wallet = wallet
    }
}
