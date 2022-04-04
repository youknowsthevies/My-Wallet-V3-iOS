// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public enum RemoteNotificationEmitterError: Error {
    case failed
}

/// Entry point for observing any incoming notification within the app
public protocol RemoteNotificationEmitting: AnyObject {
    /// An `Observable` of remote notification type
    var notification: AnyPublisher<
        RemoteNotification.NotificationType,
        RemoteNotificationEmitterError
    > { get }
}
