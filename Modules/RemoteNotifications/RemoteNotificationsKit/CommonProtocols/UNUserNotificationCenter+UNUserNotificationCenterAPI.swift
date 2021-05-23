// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UserNotifications

public protocol UNUserNotificationCenterAPI: class {
    var delegate: UNUserNotificationCenterDelegate? { get set }
    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void)
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void)

    func getAuthorizationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void)
}

extension UNUserNotificationCenter: UNUserNotificationCenterAPI {
    public func getAuthorizationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void) {
        getNotificationSettings { settings in
            completionHandler(settings.authorizationStatus)
        }
    }
}
