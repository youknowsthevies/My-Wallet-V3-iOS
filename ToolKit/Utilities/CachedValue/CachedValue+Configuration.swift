//
//  CachedValue+Configuration.swift
//  ToolKit
//
//  Created by Daniel Huri on 04/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

/// A configuration for `CachedValue`
public struct CachedValueConfiguration {
    
    /// A refresh type
    public enum RefreshType {
        
        /// Refresh once upon subscription
        case onSubscription
        
        /// Refresh periodically
        case periodic(seconds: TimeInterval)
        
        /// Custom configuration for refresh
        case custom(() -> Single<Bool>)
    }
    
    public enum FetchPriority {

        /// Fetches using the latest request. drop previous ones
        case throttle(milliseconds: Int, scheduler: SchedulerType)
        
        /// Fetch all, Use whatever result come first.
        case fetchAll
    }
    
    let flushNotificationName: Notification.Name?
    let fetchNotificationName: Notification.Name?
    let refreshType: RefreshType
    let scheduler: SchedulerType
    let fetchPriority: FetchPriority
    let identifier: String?

    public init(identifier: String? = nil,
                refreshType: RefreshType,
                scheduler: SchedulerType = generateScheduler(),
                fetchPriority: FetchPriority = .fetchAll,
                flushNotificationName: Notification.Name? = nil,
                fetchNotificationName: Notification.Name? = nil) {
        self.identifier = identifier
        self.scheduler = scheduler
        self.refreshType = refreshType
        self.fetchPriority = fetchPriority
        self.flushNotificationName = flushNotificationName
        self.fetchNotificationName = fetchNotificationName
    }
}

extension CachedValueConfiguration {
    public static func generateScheduler() -> SchedulerType {
        SerialDispatchQueueScheduler(internalSerialQueueName: "internal-\(UUID().uuidString)")
    }
}
