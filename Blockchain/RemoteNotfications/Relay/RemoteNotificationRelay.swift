// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FirebaseMessaging
import PlatformKit
import RxRelay
import RxSwift
import ToolKit
import UserNotifications

/// The class is responsible for receiving notifications and streaming to subscribers
final class RemoteNotificationRelay: NSObject {

    // MARK: - Properties

    private let relay = PublishRelay<RemoteNotification.NotificationType>()

    private let userNotificationCenter: UNUserNotificationCenterAPI
    private let messagingService: FCMServiceAPI

    // MARK: - Setup

    init(userNotificationCenter: UNUserNotificationCenterAPI = UNUserNotificationCenter.current(),
         messagingService: FCMServiceAPI = Messaging.messaging()) {
        self.userNotificationCenter = userNotificationCenter
        self.messagingService = messagingService
        super.init()
        userNotificationCenter.delegate = self
    }
}

// MARK: - RemoteNotificationEmitting

extension RemoteNotificationRelay: RemoteNotificationEmitting {
    var notification: Observable<RemoteNotification.NotificationType> {
        relay.asObservable()
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension RemoteNotificationRelay: UNUserNotificationCenterDelegate {

    /// Called upon actions the user performs e.g tapping the iOS notification view
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        Logger.shared.debug("notification received with info: \(userInfo)")

        messagingService.appDidReceiveMessage(userInfo)

        completionHandler()
    }

    /// Called upon receiving a notification, only if the app is foregrounded.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        Logger.shared.debug("notification received with info: \(userInfo)")

        messagingService.appDidReceiveMessage(userInfo)

        // Choose to display the default iOS notification
        completionHandler([.alert, .badge, .sound])
    }
}
