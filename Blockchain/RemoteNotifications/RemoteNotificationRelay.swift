// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FirebaseMessaging
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import RxRelay
import RxSwift
import ToolKit
import UserNotifications

/// The class is responsible for receiving notifications and streaming to subscribers
final class RemoteNotificationRelay: NSObject {

    // MARK: - Properties

    private let relay = PublishRelay<RemoteNotification.NotificationType>()

    private let userNotificationCenter: UNUserNotificationCenterAPI
    private let messagingService: FirebaseCloudMessagingServiceAPI
    private let secureChannelNotificationRelay: SecureChannelNotificationRelaying

    // MARK: - Setup

    init(
        userNotificationCenter: UNUserNotificationCenterAPI = UNUserNotificationCenter.current(),
        messagingService: FirebaseCloudMessagingServiceAPI = Messaging.messaging(),
        secureChannelNotificationRelay: SecureChannelNotificationRelaying = resolve()
    ) {
        self.userNotificationCenter = userNotificationCenter
        self.messagingService = messagingService
        self.secureChannelNotificationRelay = secureChannelNotificationRelay
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

extension RemoteNotificationRelay: RemoteNotificationBackgroundReceiving {
    func didReceiveRemoteNotification(
        _ userInfo: [AnyHashable: Any],
        onApplicationState applicationState: UIApplication.State,
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        let result = secureChannelNotificationRelay.didReceiveRemoteNotification(
            userInfo,
            onApplicationState: applicationState,
            fetchCompletionHandler: completionHandler
        )
        switch result {
        case true:
            // SecureChannelNotificationRelaying reacted to the given input.
            return
        case false:
            // SecureChannelNotificationRelaying did not react to the given input.
            completionHandler(.noData)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension RemoteNotificationRelay: UNUserNotificationCenterDelegate {

    /// Use this method to process the user's response to a notification.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        Logger.shared.debug("Notification didReceive: \(userInfo)")
        if secureChannelNotificationRelay.isSecureChannelNotification(userInfo) {
            secureChannelNotificationRelay.didReceiveSecureChannelNotification(userInfo)
        } else {
            messagingService.appDidReceiveMessage(userInfo)
        }
        completionHandler()
    }

    /// If the app is in foreground when a notification arrives, the shared user notification
    /// center calls this method to deliver the notification directly to the app.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        Logger.shared.debug("Notification willPresent: \(userInfo)")
        if secureChannelNotificationRelay.isSecureChannelNotification(userInfo) {
            secureChannelNotificationRelay.didReceiveSecureChannelNotification(userInfo)
            completionHandler([])
        } else {
            messagingService.appDidReceiveMessage(userInfo)
            completionHandler(.defaultPresentationOptions)
        }
    }
}

extension UNNotificationPresentationOptions {
    static let defaultPresentationOptions: UNNotificationPresentationOptions = {
        [.banner, .list, .badge, .sound]
    }()
}
