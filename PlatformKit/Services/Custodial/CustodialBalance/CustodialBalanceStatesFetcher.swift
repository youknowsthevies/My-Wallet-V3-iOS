//
//  CustodialBalanceStatesFetcher.swift
//  PlatformKit
//
//  Created by Paulo on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift
import ToolKit

public protocol CustodialBalanceStatesFetcherAPI: AnyObject {
    var isFunded: Observable<Bool> { get }
    var balanceType: BalanceType { get }
    var balanceStates: Single<CustodialAccountBalanceStates> { get }
    var balanceStatesObservable: Observable<CustodialAccountBalanceStates> { get }
    var balanceFetchTriggerRelay: PublishRelay<Void> { get }
    func setupIfNeeded()
}

public final class CustodialBalanceStatesFetcher: CustodialBalanceStatesFetcherAPI {

    // MARK: - Types
    
    public typealias Fetch = () -> Single<CustodialAccountBalanceStates>
    
    // MARK: - Public Properties
    
    public let balanceType: BalanceType
    
    public var balanceStates: Single<CustodialAccountBalanceStates> {
        balanceStatesObservable
            .take(1)
            .asSingle()
    }
     
    public var balanceStatesObservable: Observable<CustodialAccountBalanceStates> {
        _ = setup
        return balanceRelay.asObservable()
    }

    public var isFunded: Observable<Bool> {
        _ = setup
        return balanceRelay.map { $0 != .absent }
    }

    public let balanceFetchTriggerRelay = PublishRelay<Void>()

    // MARK: - Private Properties

    private let scheduler: SchedulerType
    private let balanceRelay: BehaviorRelay<CustodialAccountBalanceStates>
    private let disposeBag = DisposeBag()
    private let fetch: Fetch
    
    private lazy var setup: Void = {
        balanceFetchTriggerRelay
            .throttle(
                .milliseconds(500),
                scheduler: scheduler
            )
            .observeOn(scheduler)
            .flatMap(weak: self) { (self, _: ()) in
                self.fetch()
                    .catchErrorJustReturn(.absent)
                    .asObservable()
            }
            .bindAndCatch(to: balanceRelay)
            .disposed(by: disposeBag)
    }()
    
    // MARK: Init

    public init(custodialType: BalanceType.CustodialType,
                fetch: @escaping Fetch,
                scheduler: SchedulerType) {
        self.balanceRelay = BehaviorRelay(value: .absent)
        self.balanceType = .custodial(custodialType)
        self.scheduler = scheduler
        self.fetch = fetch
    }
    
    public func setupIfNeeded() {
        _ = setup
    }
}

// MARK: - Initializers

extension CustodialBalanceStatesFetcher {
    
    public convenience init(service: TradingBalanceServiceAPI,
                            scheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .background)) {
        self.init(
            custodialType: .trading,
            fetch: { service.fetchBalances() },
            scheduler: scheduler
        )
    }
}
