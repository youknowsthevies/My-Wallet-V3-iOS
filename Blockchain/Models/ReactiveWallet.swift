//
//  Wallet+Rx.swift
//  Blockchain
//
//  Created by Daniel Huri on 05/11/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift

/// An extension to `Wallet` which makes wallet fuctionality Rx friendly.
final class ReactiveWallet: ReactiveWalletAPI {

    var waitUntilInitialized: Observable<Void> {
        initializationState
            .map { state -> Void in
                if state == .uninitialized {
                    throw WalletSetup.StateError.walletUnitinialized
                }
                return ()
            }
            .retry(
                .delayed(maxCount: .max, time: 1),
                scheduler: MainScheduler.instance,
                shouldRetry: { error -> Bool in
                    switch error {
                    case WalletSetup.StateError.walletUnitinialized:
                        return true
                    default:
                        return false
                    }
                }
            )
            .share()
    }

    var waitUntilInitializedSingle: Single<Void> {
        waitUntilInitialized
            .take(1)
            .asSingle()
    }

    /// A `Single` that streams a boolean element indicating whether the wallet is initialized
    private var initializationState: Observable<WalletSetup.State> {
        Observable
            .create(weak: self) { (self, observer) -> Disposable in
                if self.wallet.isInitialized() {
                    observer.on(.next(.initialized))
                } else {
                    observer.on(.next(.uninitialized))
                }
                return Disposables.create()
            }
            .subscribeOn(MainScheduler.instance)

    }

    private let wallet: Wallet

    init(wallet: Wallet) {
        self.wallet = wallet
    }
}
