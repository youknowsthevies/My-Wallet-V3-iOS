// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

@testable import Blockchain

final class MockRemoteNotificationRelay: RemoteNotificationEmitting {
    let relay = PublishRelay<RemoteNotification.NotificationType>()
    var notification: Observable<RemoteNotification.NotificationType> {
        relay.asObservable()
    }
}
