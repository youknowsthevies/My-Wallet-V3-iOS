//
//  CustodialBalanceFetcher.swift
//  PlatformKit
//
//  Created by Paulo on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift
import ToolKit

public final class CustodialCryptoBalanceFetcher: CustodialAccountBalanceFetching {

    // MARK: - Types
    
    public typealias Fetch = (CryptoCurrency) -> Single<CryptoValue?>
    
    // MARK: - Public Properties
    
    public let balanceType: BalanceType
    
    public var balance: Single<CryptoValue> {
        balanceObservable
            .take(1)
            .asSingle()
    }
     
    public var balanceObservable: Observable<CryptoValue> {
        _ = setup
        let currencyType = self.currencyType
        return balanceRelay
            .map { $0 ?? CryptoValue.zero(assetType: currencyType) }
    }

    public var isFunded: Observable<Bool> {
        _ = setup
        return balanceRelay.map { $0 != nil }
    }

    public let balanceFetchTriggerRelay = PublishRelay<Void>()

    // MARK: - Private Properties
    
    private lazy var setup: Void = {
        balanceFetchTriggerRelay
            .throttle(
                .milliseconds(100),
                latest: false,
                scheduler: scheduler
            )
            .flatMapLatest(weak: self) { (self, _) -> Observable<CryptoValue?> in
                self.fetch(self.currencyType)
                    .catchErrorJustReturn(nil)
                    .asObservable()
            }
            .bindAndCatch(to: balanceRelay)
            .disposed(by: disposeBag)
    }()

    private let fetch: Fetch
    private let scheduler: SchedulerType
    private let balanceRelay = BehaviorRelay<CryptoValue?>(value: nil)
    private let currencyType: CryptoCurrency
    private let disposeBag = DisposeBag()
    
    // MARK: Init

    init(custodialType: BalanceType.CustodialType,
         currencyType: CryptoCurrency,
         fetch: @escaping Fetch,
         scheduler: SchedulerType) {
        self.currencyType = currencyType
        self.balanceType = .custodial(custodialType)
        self.fetch = fetch
        self.scheduler = scheduler
    }
}

// MARK: - Initializers

extension CustodialCryptoBalanceFetcher {
    
    public convenience init(currencyType: CryptoCurrency,
                            service: TradingBalanceServiceAPI,
                            scheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .background)) {
        let fetch = { (currency: CryptoCurrency) in
            service.balance(for: currency).map { $0.balance?.available }
        }
        
        self.init(
            custodialType: .trading,
            currencyType: currencyType,
            fetch: fetch,
            scheduler: scheduler
        )
    }
    
    public convenience init(currencyType: CryptoCurrency,
                            service: SavingAccountServiceAPI,
                            scheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .background)) {
        let fetch = { (currency: CryptoCurrency) in
            service.balance(for: currency).map { $0.balance?.available }
        }
        
        self.init(
            custodialType: .savings,
            currencyType: currencyType,
            fetch: fetch,
            scheduler: scheduler
        )
    }
}
