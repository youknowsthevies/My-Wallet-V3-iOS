// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

/// Entry point for observing any incoming notification within the app
protocol RemoteNotificationEmitting: AnyObject {
    var notification: Observable<RemoteNotification.NotificationType> { get }
}
