//
//  EmptyTransactionalActivityItemEventService.swift
//  Blockchain
//
//  Created by Paulo on 10/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift

final class EmptyTransactionalActivityItemEventService: TransactionalActivityItemEventServiceAPI {
    var transactionActivityEvents: Single<[TransactionalActivityItemEvent]> { .just([]) }

    var transactionActivityObservable: Observable<[TransactionalActivityItemEvent]> { .just([]) }

    var state: Observable<ActivityItemEventsLoadingState> { .just(.loaded(next: [])) }

    let fetchTriggerRelay: PublishRelay<Void> = .init()
}
