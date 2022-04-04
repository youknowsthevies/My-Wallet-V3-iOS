// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import RemoteNotificationsKit
import UIKit

final class MockRemoteNotificationRelay: RemoteNotificationEmitting, RemoteNotificationBackgroundReceiving {

    var notification: AnyPublisher<
        RemoteNotification.NotificationType,
        RemoteNotificationEmitterError
    > {
        relay.eraseToAnyPublisher()
    }

    private let relay = PassthroughSubject<
        RemoteNotification.NotificationType,
        RemoteNotificationEmitterError
    >()

    func didReceiveRemoteNotification(
        _ userInfo: [AnyHashable: Any],
        onApplicationState applicationState: UIApplication.State,
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        completionHandler(.noData)
    }
}
