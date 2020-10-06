//
//  BitcoinCashAssetBalanceFetcher.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxCocoa
import RxSwift

final class BitcoinCashAssetBalanceFetcher: CryptoAccountBalanceFetching {
    
    // MARK: - Exposed Properties
    
    var accountType: SingleAccountType {
        .nonCustodial
    }
    
    var balance: Single<CryptoValue> {
        Single
            .just(CryptoValue.bitcoinCash(satoshis: Int(wallet.getBchBalance())))
    }
    
    var pendingBalanceMoneyObservable: Observable<MoneyValue> {
        pendingBalanceMoney
            .asObservable()
    }
    
    var pendingBalanceMoney: Single<MoneyValue> {
        Single.just(MoneyValue.zero(currency: .bitcoinCash))
    }
    
    var balanceMoney: Single<MoneyValue> {
        Single.just(CryptoValue.bitcoinCash(satoshis: Int(wallet.getBchBalance())))
            .map { .init(cryptoValue: $0) }
    }
    
    var balanceObservable: Observable<CryptoValue> {
        balanceRelay.asObservable()
    }
    
    var balanceMoneyObservable: Observable<MoneyValue> {
        balanceObservable.moneyValue
    }
    
    let balanceFetchTriggerRelay = PublishRelay<Void>()
    
    // MARK: - Private Properties
    
    private let balanceRelay = PublishRelay<CryptoValue>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    private let wallet: Wallet
    
    // MARK: - Setup
    
    init(wallet: Wallet = WalletManager.shared.wallet) {
        self.wallet = wallet
        balanceFetchTriggerRelay
            .throttle(
                .milliseconds(100),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
            .observeOn(MainScheduler.asyncInstance)
            .flatMapLatest(weak: self) { (self, _) in
                self.balance.asObservable()
            }
            .bindAndCatch(to: balanceRelay)
            .disposed(by: disposeBag)
    }
}
