// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import NetworkKit
import UIKit

extension DependencyContainer {

    // MARK: - RemoteNotificationsKit Module

    public static var remoteNotificationsKit = module {

        factory {
            RemoteNotificationAuthorizer(
                application: UIApplication.shared,
                analyticsRecorder: DIKit.resolve(),
                userNotificationCenter: UNUserNotificationCenter.current()
            ) as RemoteNotificationAuthorizing
        }

        factory {
            RemoteNotificationNetworkService(
                pushNotificationsUrl: BlockchainAPI.shared.pushNotificationsUrl,
                networkAdapter: DIKit.resolve()
            ) as RemoteNotificationNetworkServicing
        }

        factory {
            RemoteNotificationService(
                authorizer: DIKit.resolve(),
                notificationRelay: DIKit.resolve(),
                backgroundReceiver: DIKit.resolve(),
                externalService: DIKit.resolve(),
                networkService: DIKit.resolve(),
                sharedKeyRepository: DIKit.resolve(),
                guidRepository: DIKit.resolve()
            ) as RemoteNotificationService
        }

        factory { () -> RemoteNotificationServicing in
            let service: RemoteNotificationService = DIKit.resolve()
            return service as RemoteNotificationServicing
        }

        single { () -> RemoteNotificationServiceContaining in
            let service: RemoteNotificationService = DIKit.resolve()
            return RemoteNotificationServiceContainer(
                service: service
            ) as RemoteNotificationServiceContaining
        }
    }
}
