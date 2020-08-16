//
//  BitcoinAssetBalanceFetcher.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxRelay
import RxSwift

/// Fetches balance of all wallets
public final class BitcoinAllAccountsBalanceFetcher: CryptoAccountBalanceFetching {
        
    // MARK: - Exposed Properties
    
    public var balanceType: BalanceType {
        .nonCustodial
    }
    
    public var balance: Single<CryptoValue> {
        activeAccountAddresses
            .flatMap(weak: self) { (self, activeAccounts) -> Single<BitcoinBalanceResponse> in
                self.client.balances(for: activeAccounts)
            }
            .map { balances -> CryptoValue in
                BitcoinBalances(balances: balances).total
            }
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
    
    private var activeAccountAddresses: Single<[String]> {
        repository.activeAccounts
            .map { $0.map(\.publicKey) }
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

    private let client: APIClientAPI
    private let repository: BitcoinWalletAccountRepository
    
    // MARK: - Setup
    
    public convenience init() {
        self.init(repository: resolve(), client: resolve())
    }
    
    init(repository: BitcoinWalletAccountRepository, client: APIClientAPI) {
        self.repository = repository
        self.client = client
    }
}

struct BitcoinBalances {
    
    let total: CryptoValue
    
    private let addresses: [String: CryptoValue]
    
    init(balances: BitcoinBalanceResponse) {
        let balanceByAddress = balances.compactMapValues { item -> CryptoValue? in
            CryptoValue(minor: "\(item.finalBalance)", cryptoCurrency: .bitcoin)
        }
        let totalBalance = try? balanceByAddress
            .values
            .reduce(CryptoValue.bitcoinZero, +)
        self.addresses = balanceByAddress
        self.total = totalBalance ?? CryptoValue.bitcoinZero
    }
    
    func balance(for account: BitcoinWalletAccount) -> CryptoValue? {
        addresses[account.publicKey]
    }
}
