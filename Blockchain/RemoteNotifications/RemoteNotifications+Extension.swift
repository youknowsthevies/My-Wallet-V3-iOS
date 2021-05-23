// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RemoteNotificationsKit
import UserNotifications

/// analyticsRecorder dependency can only be resolved in the main target
extension RemoteNotificationAuthorizer {
    convenience init() {
        self.init(application: UIApplication.shared,
                  analyticsRecorder: resolve(),
                  userNotificationCenter: UNUserNotificationCenter.current(),
                  options: [.alert, .badge, .sound])
    }
}

/// WalletManager is only available in main target
extension RemoteNotificationService {
    convenience init(walletRepository: SharedKeyRepositoryAPI & GuidRepositoryAPI = WalletManager.shared.repository) {
        self.init(authorizer: RemoteNotificationAuthorizer(),
                  notificationRelay: RemoteNotificationRelay(),
                  externalService: ExternalNotificationServiceProvider(),
                  networkService: RemoteNotificationNetworkService(),
                  walletRepository: walletRepository)
    }
}
