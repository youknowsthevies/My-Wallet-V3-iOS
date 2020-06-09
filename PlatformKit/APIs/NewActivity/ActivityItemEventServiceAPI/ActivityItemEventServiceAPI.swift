//
//  ActivityItemEventServiceAPI.swift
//  PlatformKit
//
//  Created by Alex McGregor on 6/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

public protocol ActivityItemEventServiceAPI {
    var transactional: TransactionalActivityItemEventServiceAPI { get }
    var buy: BuyActivityItemEventServiceAPI { get }
    var swap: SwapActivityItemEventServiceAPI { get }
    
    var activityEvents: Single<[ActivityItemEvent]> { get }
    var activityLoadingStateObservable: Observable<ActivityItemEventsLoadingState> { get }
    
    func refresh()
}
