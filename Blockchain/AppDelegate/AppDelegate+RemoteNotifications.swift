// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

extension AppDelegate {

    struct RemoteNotification: Decodable {
        let deepLinkURL: URL?

        init(decoding userInfo: [AnyHashable: Any]) throws {
            self = try AnyDecoder().decode(RemoteNotification.self, from: userInfo)
        }
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if let notification = try? RemoteNotification(decoding: userInfo),
           let url = notification.deepLinkURL
        {
            app.post(
                event: blockchain.app.process.deep_link,
                context: [blockchain.app.process.deep_link.url: url]
            )
        }

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
