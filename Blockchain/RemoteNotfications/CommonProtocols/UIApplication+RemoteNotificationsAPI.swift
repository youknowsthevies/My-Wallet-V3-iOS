// Copyright © Blockchain Luxembourg S.A. All rights reserved.

protocol UIApplicationRemoteNotificationsAPI: class {
    func registerForRemoteNotifications()
}

extension UIApplication: UIApplicationRemoteNotificationsAPI {}
