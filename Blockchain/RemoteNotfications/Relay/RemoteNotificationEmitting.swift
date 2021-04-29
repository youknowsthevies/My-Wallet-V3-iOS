// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

/// Entry point for observing any incoming notification within the app
protocol RemoteNotificationEmitting: class {
    var notification: Observable<RemoteNotification.NotificationType> { get }
}
