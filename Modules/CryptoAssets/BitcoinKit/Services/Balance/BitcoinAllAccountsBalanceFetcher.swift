//
//  BitcoinAllAccountsBalanceFetcher.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinChainKit
import DIKit
import PlatformKit
import RxRelay
import RxSwift

/// Fetches balance of all wallets
public final class BitcoinAllAccountsBalanceFetcher: CryptoAccountBalanceFetching {
        
    // MARK: - Exposed Properties
    
    public var accountType: SingleAccountType {
        .nonCustodial
    }
    
    public var balance: Single<CryptoValue> {
        activeAccountAddresses
            .flatMap(weak: self) { (self, activeAccounts) -> Single<CryptoValue> in
                self.balanceService.balances(for: activeAccounts)
            }
    }
    
    public var pendingBalanceMoneyObservable: Observable<MoneyValue> {
        pendingBalanceMoney
            .asObservable()
    }
    
    public var pendingBalanceMoney: Single<MoneyValue> {
        Single.just(MoneyValue.zero(currency: .bitcoin))
    }
    
    public var balanceMoney: Single<MoneyValue> {
        balance
            .moneyValue
    }
    
    public var balanceObservable: Observable<CryptoValue> {
        _ = setup
        return balanceRelay
            .asObservable()
    }
    
    public var balanceMoneyObservable: Observable<MoneyValue> {
        balanceObservable.moneyValue
    }

    public let balanceFetchTriggerRelay = PublishRelay<Void>()
    
    // MARK: - Private Properties
    
    private var activeAccountAddresses: Single<[XPub]> {
        repository.activeAccounts
            .map { accounts in
                accounts
                    .map(\.publicKeys.xpubs)
                    .flatMap { $0 }
            }
    }
    
    private lazy var setup: Void = {
        balanceFetchTriggerRelay
            .throttle(
                .milliseconds(100),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
            .flatMapLatest(weak: self) { (self, _) in
                self.balance
                    .asObservable()
                    .materialize()
                    .filter { !$0.isStopEvent }
                    .dematerialize()
            }
            .bindAndCatch(to: balanceRelay)
            .disposed(by: disposeBag)
    }()
    
    private let balanceRelay = PublishRelay<CryptoValue>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected

    private let balanceService: BalanceServiceAPI
    private let repository: BitcoinWalletAccountRepository
    
    // MARK: - Setup
    
    public convenience init() {
        self.init(repository: resolve(), balanceService: resolve(tag: BitcoinChainKit.BitcoinChainCoin.bitcoin))
    }
    
    init(repository: BitcoinWalletAccountRepository, balanceService: BalanceServiceAPI) {
        self.repository = repository
        self.balanceService = balanceService
    }
}
