// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

extension AppDelegate {

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        viewStore.send(
            .appDelegate(.didRegisterForRemoteNotifications(.failure(error as NSError)))
        )
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        viewStore.send(
            .appDelegate(.didRegisterForRemoteNotifications(.success(deviceToken)))
        )
    }
}
