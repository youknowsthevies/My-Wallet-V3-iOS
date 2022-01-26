// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

extension AppDelegate {

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        NotificationCenter.default.post(name: UIApplication.pushNotificationReceivedNotification, object: userInfo)
        viewStore.send(
            .appDelegate(
                .didReceiveRemoteNotification(
                    application,
                    userInfo: userInfo,
                    completionHandler: completionHandler
                )
            )
        )
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        viewStore.send(
            .appDelegate(
                .didRegisterForRemoteNotifications(
                    .failure(
                        error as NSError
                    )
                )
            )
        )
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        viewStore.send(
            .appDelegate(
                .didRegisterForRemoteNotifications(
                    .success(
                        deviceToken
                    )
                )
            )
        )
    }
}
