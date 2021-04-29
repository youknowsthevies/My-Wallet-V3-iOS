// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift

final class EmptyTransactionalActivityItemEventService: TransactionalActivityItemEventServiceAPI {
    var transactionActivityEvents: Single<[TransactionalActivityItemEvent]> { .just([]) }

    var transactionActivityObservable: Observable<[TransactionalActivityItemEvent]> { .just([]) }

    var state: Observable<ActivityItemEventsLoadingState> { .just(.loaded(next: [])) }

    let fetchTriggerRelay: PublishRelay<Void> = .init()
}
