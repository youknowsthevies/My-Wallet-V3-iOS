// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

/// A protocol that encapsulates the sending of a pre-known notification token
protocol RemoteNotificationTokenSending: class {
    func sendTokenIfNeeded() -> Single<Void>
}

/// A protocol that
protocol RemoteNotificationDeviceTokenReceiving: class {
    func appDidFailToRegisterForRemoteNotifications(with error: Error)
    func appDidRegisterForRemoteNotifications(with deviceToken: Data)
}

/// An umbrella protocol that represents a single entry to common notification services
protocol RemoteNotificationServicing {
    var relay: RemoteNotificationEmitting { get }
    var authorizer: RemoteNotificationAuthorizing { get }
}
