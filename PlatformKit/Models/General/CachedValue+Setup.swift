//
//  CachedValueOld+Setup.swift
//  PlatformKit
//
//  Created by Daniel Huri on 04/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

extension CachedValueConfigurationOld {
    public static func onSubscriptionAndLogin(scheduler: SchedulerType = CachedValueConfigurationOld.generateScheduler()) -> CachedValueConfigurationOld {
        .init(
            refreshType: .onSubscription,
            scheduler: scheduler,
            flushNotificationName: .logout,
            fetchNotificationName: .login
        )
    }
    
    public static func periodicAndLogin(_ time: TimeInterval, scheduler: SchedulerType = CachedValueConfigurationOld.generateScheduler()) -> CachedValueConfigurationOld {
        .init(
            refreshType: .periodic(seconds: time),
            scheduler: scheduler,
            flushNotificationName: .logout,
            fetchNotificationName: .login
        )
    }
}

extension CachedValueConfiguration {
    
    public static func onSubscription(
        scheduler: SchedulerType = CachedValueConfiguration.generateScheduler()
    ) -> CachedValueConfiguration {
        CachedValueConfiguration(
            refreshType: .onSubscription,
            scheduler: scheduler,
            flushNotificationName: .logout
        )
    }
    
    public static func periodicAndLogin(
        _ time: TimeInterval,
        scheduler: SchedulerType = CachedValueConfiguration.generateScheduler()
    ) -> CachedValueConfiguration {
        CachedValueConfiguration(
            refreshType: .periodic(seconds: time),
            scheduler: scheduler,
            flushNotificationName: .logout,
            fetchNotificationName: .login
        )
    }
}

