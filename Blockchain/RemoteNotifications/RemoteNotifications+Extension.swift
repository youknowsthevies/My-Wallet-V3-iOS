// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RemoteNotificationsKit

extension RemoteNotificationService {
    convenience init(walletRepository: SharedKeyRepositoryAPI & GuidRepositoryAPI = WalletManager.shared.repository) {
        self.init(authorizer: RemoteNotificationAuthorizer(),
                  notificationRelay: RemoteNotificationRelay(),
                  externalService: ExternalNotificationServiceProvider(),
                  networkService: RemoteNotificationNetworkService(),
                  walletRepository: walletRepository)
    }
}
