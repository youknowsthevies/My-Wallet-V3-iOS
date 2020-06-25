//
//  CustodialBalanceFetcher.swift
//  PlatformKit
//
//  Created by Paulo on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

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
        let currencyType = self.currencyType
        return balanceRelay
            .map { $0 ?? CryptoValue.zero(assetType: currencyType) }
    }

    public var isFunded: Observable<Bool> {
        balanceRelay.map { $0 != nil }
    }

    public let balanceFetchTriggerRelay = PublishRelay<Void>()

    // MARK: - Private Properties

    private let balanceRelay: BehaviorRelay<CryptoValue?>
    private let currencyType: CryptoCurrency
    private let disposeBag = DisposeBag()
    
    // MARK: Init

    init(custodialType: BalanceType.CustodialType,
         currencyType: CryptoCurrency,
         fetch: @escaping Fetch,
         scheduler: SchedulerType) {
                
        self.balanceRelay = BehaviorRelay(value: nil)
        self.balanceType = .custodial(custodialType)
        self.currencyType = currencyType
         
        balanceFetchTriggerRelay
            .throttle(
                .milliseconds(100),
                latest: false,
                scheduler: scheduler
            )
            .flatMapLatest {
                fetch(currencyType)
                    .catchErrorJustReturn(nil)
                    .asObservable()
            }
            .bind(to: balanceRelay)
            .disposed(by: disposeBag)
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
