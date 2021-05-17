// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift
import ToolKit

public protocol CustodialBalanceStatesFetcherAPI: AnyObject {
    var isFunded: Observable<Bool> { get }
    var custodialAccountType: SingleAccountType.CustodialAccountType { get }
    var balanceStates: Single<CustodialAccountBalanceStates> { get }
    var balanceStatesObservable: Observable<CustodialAccountBalanceStates> { get }
    var balanceFetchTriggerRelay: PublishRelay<Void> { get }
    func setupIfNeeded()
}

public final class CustodialBalanceStatesFetcher: CustodialBalanceStatesFetcherAPI {

    // MARK: - Types

    public typealias Fetch = () -> Single<CustodialAccountBalanceStates>

    // MARK: - Public Properties

    public let custodialAccountType: SingleAccountType.CustodialAccountType

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

    public init(custodialAccountType: SingleAccountType.CustodialAccountType,
                fetch: @escaping Fetch,
                scheduler: SchedulerType) {
        self.balanceRelay = BehaviorRelay(value: .absent)
        self.custodialAccountType = custodialAccountType
        self.scheduler = scheduler
        self.fetch = fetch
    }

    public func setupIfNeeded() {
        _ = setup
    }
}

// MARK: - Initializers

extension CustodialBalanceStatesFetcher {

    public convenience init(tradingBalanceService: TradingBalanceServiceAPI,
                            scheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .background)) {
        self.init(
            custodialAccountType: .trading,
            fetch: { tradingBalanceService.fetchBalances() },
            scheduler: scheduler
        )
    }
}
