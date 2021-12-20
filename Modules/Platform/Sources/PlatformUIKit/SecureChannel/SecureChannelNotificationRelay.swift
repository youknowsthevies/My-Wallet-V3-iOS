// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import RxSwift
import ToolKit

public protocol SecureChannelNotificationRelaying {

    /// Method should be called when application receives a background notification.
    /// - Parameters:
    ///   - userInfo: Notification payload.
    ///   - applicationState: `UIApplication` state.
    ///   - completionHandler: `completionHandler` that will be called if this object decided to react to the notification payload.
    /// - Returns:
    ///   Boolean flag indicating if this object decided to react to the notification payload. If this flag is `false` this object will not call the `completionHandler`.
    func didReceiveRemoteNotification(
        _ userInfo: [AnyHashable: Any],
        onApplicationState applicationState: UIApplication.State,
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) -> Bool

    func isSecureChannelNotification(_ userInfo: [AnyHashable: Any]) -> Bool
    func didReceiveSecureChannelNotification(_ userInfo: [AnyHashable: Any])
}

final class SecureChannelNotificationRelay: SecureChannelNotificationRelaying {
    private typealias LocalizedString = LocalizationConstants.SecureChannel.Notification

    private let router: SecureChannelRouting
    private let service: SecureChannelAPI
    private let disposeBag = DisposeBag()
    private let analyticsRecorder: AnalyticsEventRecorderAPI

    init(
        router: SecureChannelRouting = resolve(),
        service: SecureChannelAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.router = router
        self.service = service
        self.analyticsRecorder = analyticsRecorder
    }

    func didReceiveRemoteNotification(
        _ userInfo: [AnyHashable: Any],
        onApplicationState applicationState: UIApplication.State,
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) -> Bool {
        guard isSecureChannelNotification(userInfo) else {
            return false
        }
        guard applicationState != .active else {
            defer { completionHandler(.noData) }
            didReceiveSecureChannelNotification(userInfo)
            return true
        }
        scheduleLocalNotification(userInfo: userInfo)
            .subscribe(
                onCompleted: {
                    completionHandler(.noData)
                },
                onError: { error in
                    Logger.shared.debug("Secure Channel Error: \(String(describing: error))")
                }
            )
            .disposed(by: disposeBag)
        return true
    }

    func isSecureChannelNotification(_ userInfo: [AnyHashable: Any]) -> Bool {
        (userInfo["type"] as? String) == "secure_channel"
    }

    func didReceiveSecureChannelNotification(_ userInfo: [AnyHashable: Any]) {
        service.createSecureChannelConnectionCandidate(userInfo)
            .subscribe(
                onSuccess: { [weak self] candidate in
                    self?.router.didReceiveSecureChannelCandidate(candidate)
                },
                onFailure: { [weak self] error in
                    Logger.shared.debug("Secure Channel Error: \(String(describing: error))")
                    guard let secureChannelError = error as? SecureChannelError else {
                        return
                    }
                    self?.analyticsRecorder.record(event: .secureChannelErrorReceived(error: secureChannelError))
                    self?.router.didReceiveError(secureChannelError)
                }
            )
            .disposed(by: disposeBag)
    }

    private func scheduleLocalNotification(userInfo: [AnyHashable: Any]) -> Completable {
        service.createSecureChannelConnectionCandidate(userInfo)
            .flatMapCompletable(weak: self) { (self, candidate) in
                self.scheduleLocalNotification(candidate: candidate, userInfo: userInfo)
            }
    }

    private func scheduleLocalNotification(
        candidate: SecureChannelConnectionCandidate,
        userInfo: [AnyHashable: Any]
    ) -> Completable {
        let title: String
        let body: String
        if candidate.isAuthorized {
            title = LocalizedString.Authorized.title
            body = LocalizedString.Authorized.subtitle
        } else {
            title = LocalizedString.New.title
            body = LocalizedString.New.subtitle
        }

        let content = UNMutableNotificationContent()
        // Configure notification.
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = userInfo.filter { item -> Bool in
            (item.key as? String) != "aps"
        }
        // Configure the trigger date.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(
            identifier: uuidString,
            content: content,
            trigger: trigger
        )

        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request)
        return .empty()
    }
}
