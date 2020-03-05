//
//  CachedValue+Setup.swift
//  PlatformKit
//
//  Created by Daniel Huri on 04/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit

extension CachedValueConfiguration {
    public static var onSubscriptionAndLogin: CachedValueConfiguration {
        .init(
            refreshType: .onSubscription,
            flushNotificationName: .logout,
            fetchNotificationName: .login
        )
    }
    
    public static func periodicAndLogin(_ time: TimeInterval) -> CachedValueConfiguration {
        .init(
            refreshType: .periodic(time),
            flushNotificationName: .logout,
            fetchNotificationName: .login
        )
    }
}
