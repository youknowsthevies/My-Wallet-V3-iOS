//
//  CachedValueOld+Setup.swift
//  PlatformKit
//
//  Created by Daniel Huri on 04/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

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

