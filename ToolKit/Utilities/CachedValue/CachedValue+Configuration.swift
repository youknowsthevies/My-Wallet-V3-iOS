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
    public enum RefreshType: Hashable {
        
        /// Refresh once upon subscription
        case onSubscription
        
        /// Refresh periodically
        case periodic(TimeInterval)
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
    let fetchPriority: FetchPriority
    let identifier: String?

    public init(identifier: String? = nil,
                refreshType: RefreshType,
                fetchPriority: FetchPriority = .fetchAll,
                flushNotificationName: Notification.Name? = nil,
                fetchNotificationName: Notification.Name? = nil) {
        self.identifier = identifier
        self.refreshType = refreshType
        self.fetchPriority = fetchPriority
        self.flushNotificationName = flushNotificationName
        self.fetchNotificationName = fetchNotificationName
    }
}
