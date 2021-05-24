// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

protocol UIApplicationRemoteNotificationsAPI: class {
    func registerForRemoteNotifications()
}

extension UIApplication: UIApplicationRemoteNotificationsAPI {}
