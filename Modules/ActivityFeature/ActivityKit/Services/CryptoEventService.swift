// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift

final class CryptoEventService: CryptoItemEventServiceAPI {

    var activityEvents: Single<[ActivityItemEvent]> {
        let transactions: Single<[ActivityItemEvent]> = transactional
            .transactionActivityEvents
            .map { items in items.map { .transactional($0) } }
            .catchErrorJustReturn([])

        let buySells: Single<[ActivityItemEvent]> = buySell
            .buySellActivityEvents
            .map { items in items.map { .buySell($0) } }
            .catchErrorJustReturn([])

        let swaps: Single<[ActivityItemEvent]> = swap
            .swapActivityEvents
            .map { items in items.map { .swap($0) } }
            .catchErrorJustReturn([])

        return Single.zip(transactions, buySells, swaps).map { $0.0 + $0.1 + $0.2 }
    }

    var activityObservable: Observable<[ActivityItemEvent]> {
        activityEvents
            .asObservable()
    }

    var activityLoadingStateObservable: Observable<ActivityItemEventsLoadingState> {
        _ = setup
        return activityLoadingStateRelay.asObservable()
    }

    let transactional: TransactionalActivityItemEventServiceAPI
    let buySell: BuySellActivityItemEventServiceAPI
    let swap: SwapActivityItemEventServiceAPI

    // MARK: - Private Properties

    private let activityLoadingStateRelay = BehaviorRelay<ActivityItemEventsLoadingState>(value: .loading)
    private let disposeBag = DisposeBag()

    private lazy var setup: Void = {
        Observable
            .combineLatest(
                transactional.state,
                buySell.state,
                swap.state
            )
            .map(weak: self) { (_, values) -> ActivityItemEventsLoadingState in
                [values.0, values.1, values.2].reduce()
            }
            .catchErrorJustReturn(.loaded(next: []))
            .bindAndCatch(to: activityLoadingStateRelay)
            .disposed(by: disposeBag)
    }()

    // MARK: - Setup

    init(transactional: TransactionalActivityItemEventServiceAPI,
         buySell: BuySellActivityItemEventServiceAPI,
         swap: SwapActivityItemEventServiceAPI) {
        self.transactional = transactional
        self.buySell = buySell
        self.swap = swap
    }

    func refresh() {
        transactional.fetchTriggerRelay.accept(())
        buySell.fetchTriggerRelay.accept(())
        swap.fetchTriggerRelay.accept(())
    }
}
