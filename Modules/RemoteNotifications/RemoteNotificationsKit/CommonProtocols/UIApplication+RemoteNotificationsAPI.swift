// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

public protocol UIApplicationRemoteNotificationsAPI: class {
    func registerForRemoteNotifications()
}

extension UIApplication: UIApplicationRemoteNotificationsAPI {}
