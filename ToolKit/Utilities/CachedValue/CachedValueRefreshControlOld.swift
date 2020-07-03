//
//  CachedValueRefreshControlOld.swift
//  ToolKit
//
//  Created by Daniel Huri on 05/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

final class CachedValueRefreshControlOld {

    enum Action {
        
        /// Flush the cache
        case flush
        
        /// Fetch the data and cache it
        case fetch
    }
    
    /// Streams the action (push events into `CachedValue`)
    var action: Observable<Action> {
        actionRelay.asObservable()
    }
    
    /// Should refresh (explicitly asks `CachedValue` for updates)
    var shouldRefresh: Single<Bool> {
        switch configuration.refreshType {
        case .onSubscription:
            return .just(false)
        case .periodic(let refreshInterval):
            let lastRefreshInterval = Date(timeIntervalSinceNow: -refreshInterval)
            let shouldRefresh = lastRefreshRelay.value.compare(lastRefreshInterval) == .orderedAscending
            return .just(shouldRefresh)
        case .custom(let shouldRefresh):
            return shouldRefresh()
        }
    }
    
    /// The action relay
    let actionRelay = PublishRelay<Action>()
    private let lastRefreshRelay = BehaviorRelay(value: Date.distantPast)
    private let configuration: CachedValueConfigurationOld
    
    init(configuration: CachedValueConfigurationOld) {
        self.configuration = configuration
        
        if let notification = configuration.flushNotificationName {
            NotificationCenter.when(notification) { [weak actionRelay] _ in
                actionRelay?.accept(.flush)
            }
        }
        
        if let notification = configuration.fetchNotificationName {
            NotificationCenter.when(notification) { [weak actionRelay] _ in
                actionRelay?.accept(.fetch)
            }
        }
    }
    
    func update(refreshDate: Date) {
        lastRefreshRelay.accept(refreshDate)
    }
}
