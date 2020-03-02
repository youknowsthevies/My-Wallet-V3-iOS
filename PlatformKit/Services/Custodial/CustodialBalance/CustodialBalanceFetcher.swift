//
//  CustodialBalanceFetcher.swift
//  PlatformKit
//
//  Created by Paulo on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

public final class CustodialCryptoBalanceFetcher: CustodialAccountBalanceFetching {

    // MARK: - Public Properties

    public let balanceType: BalanceType = .custodial
    
    public var balance: Single<CryptoValue> {
        return balanceObservable
            .take(1)
            .asSingle()
    }
    
    public var balanceObservable: Observable<CryptoValue> {
        let asset = self.asset
        return balanceRelay
            .map { $0 ?? CryptoValue.zero(assetType: asset) }
    }

    public var isFunded: Single<Bool> {
        balanceRelay
            .map { $0 != nil }
            .take(1)
            .asSingle()
    }

    public let balanceFetchTriggerRelay = PublishRelay<Void>()

    // MARK: - Private Properties

    private let balanceRelay = PublishRelay<CryptoValue?>()
    private let disposeBag = DisposeBag()
    private let asset: CryptoCurrency
    private let custodialBalanceService: CustodialBalanceServiceAPI

    // MARK: Init

    init(currencyType: CryptoCurrency, service: CustodialBalanceServiceAPI, scheduler: SchedulerType) {
        asset = currencyType
        custodialBalanceService = service

        balanceFetchTriggerRelay
            .throttle(
                .milliseconds(100),
                scheduler: scheduler
            )
            .flatMapLatest(weak: self) { (self, _: ()) -> Observable<CustodialBalanceState> in
                self.custodialBalanceService.balance(for: self.asset).asObservable()
            }
            .map { $0.custodialBalance?.available }
            .bind(to: balanceRelay)
            .disposed(by: disposeBag)
    }

    public convenience init(currencyType: CryptoCurrency, service: CustodialBalanceServiceAPI) {
        self.init(currencyType: currencyType, service: service, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
    }
}

fileprivate extension CustodialBalanceState {
    var custodialBalance: CustodialBalance? {
        switch self {
        case .absent:
            return nil
        case .present(let custodialBalance):
            return custodialBalance
        }
    }
}
