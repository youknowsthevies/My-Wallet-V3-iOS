// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

extension CachedValueConfiguration {

    /// Refresh `.onSubscription` (only when cache is empty) and
    /// flushes the cached value on login and logout.
    public static func onSubscription(
        schedulerIdentifier: String
    ) -> CachedValueConfiguration {
        onSubscription(
            scheduler: CachedValueConfiguration
                .generateScheduler(identifier: schedulerIdentifier)
        )
    }

    /// Refresh `.onSubscription` (only when cache is empty) and
    /// flushes the cached value on login and logout.
    public static func onSubscription(
        scheduler: SchedulerType
    ) -> CachedValueConfiguration {
        CachedValueConfiguration(
            refreshType: .onSubscription,
            scheduler: scheduler,
            flushNotificationNames: [.login, .logout]
        )
    }

    /// Refresh `.periodic` by the given `TimeInterval` and
    /// flushes the cached value on login and logout.
    public static func periodic(
        seconds: TimeInterval,
        schedulerIdentifier: String
    ) -> CachedValueConfiguration {
        periodic(
            seconds: seconds,
            scheduler: CachedValueConfiguration
                .generateScheduler(identifier: schedulerIdentifier)
        )
    }

    /// Refresh `.periodic` by the given `TimeInterval` and
    /// flushes the cached value on login and logout.
    public static func periodic(
        seconds: TimeInterval,
        scheduler: SchedulerType
    ) -> CachedValueConfiguration {
        CachedValueConfiguration(
            refreshType: .periodic(seconds: seconds),
            scheduler: scheduler,
            flushNotificationNames: [.login, .logout]
        )
    }
}
