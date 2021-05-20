// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

/// A service that coordinates
final class RemoteNotificationService: RemoteNotificationServicing {

    // MARK: - ServiceError

    private enum ServiceError: Error {
        case unauthorizedRemoteNotificationsPermission
    }

    // MARK: - RemoteNotificationServicing (services)

    let authorizer: RemoteNotificationAuthorizing
    let backgroundReceiver: RemoteNotificationBackgroundReceiving
    let relay: RemoteNotificationEmitting

    // MARK: - Privately used services

    private let externalService: ExternalNotificationProviding
    private let networkService: RemoteNotificationNetworkServicing
    private let walletRepository: SharedKeyRepositoryAPI & GuidRepositoryAPI

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(authorizer: RemoteNotificationAuthorizing = RemoteNotificationAuthorizer(),
         notificationRelay: RemoteNotificationEmitting & RemoteNotificationBackgroundReceiving = RemoteNotificationRelay(),
         externalService: ExternalNotificationProviding = ExternalNotificationServiceProvider(),
         networkService: RemoteNotificationNetworkServicing = RemoteNotificationNetworkService(),
         walletRepository: SharedKeyRepositoryAPI & GuidRepositoryAPI = WalletManager.shared.repository) {
        self.authorizer = authorizer
        self.externalService = externalService
        self.networkService = networkService
        self.walletRepository = walletRepository
        self.relay = notificationRelay
        self.backgroundReceiver = notificationRelay
    }
}

// MARK: - RemoteNotificationTokenSending

extension RemoteNotificationService: RemoteNotificationTokenSending {

    /// Sends the token. Only if remote notification permission was pre-authorized.
    /// Typically called after the user has identified himself with his PIN since the
    /// user credentials are known at that time
    func sendTokenIfNeeded() -> Single<Void> {
        authorizer.isAuthorized
            .filter { isAuthorized in
                guard isAuthorized else {
                    throw ServiceError.unauthorizedRemoteNotificationsPermission
                }
                return true
            }
            .flatMap(weak: self) { (self, _) -> Single<String> in
                self.externalService.token
            }
            .flatMap(weak: self, { (self, token) -> Single<Void> in
                self.networkService.register(with: token, using: self.walletRepository)
            })
    }
}

// MARK: - RemoteNotificationDeviceTokenReceiving

extension RemoteNotificationService: RemoteNotificationDeviceTokenReceiving {
    func appDidFailToRegisterForRemoteNotifications(with error: Error) {
        Logger.shared.info("Remote Notification Registration Failed with error: \(error)")
    }

    func appDidRegisterForRemoteNotifications(with deviceToken: Data) {
        Logger.shared.info("Remote Notification Registration Succeeded")

        // FCM service must be informed about the new token
        externalService.didReceiveNewApnsToken(token: deviceToken)

        // Send the token
        sendTokenIfNeeded()
            .subscribe(
                onError: { error in
                    Logger.shared.error("Remote notification token could not be sent to the backend. received error: \(error)")
                }
            )
            .disposed(by: disposeBag)
    }
}
