// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import UserNotifications

public typealias RemoteNotificationAuthorizing = RemoteNotificationRegistering &
                                          RemoteNotificationAuthorizationRequesting &
                                          RemoteNotificationAuthorizationStatusProviding

/// A protocol that encapsulates the registration to any notification service
/// The app delegate should hold its instance and inform it about registration events.
public protocol RemoteNotificationRegistering: class {
    func registerForRemoteNotificationsIfAuthorized() -> Single<Void>
}

/// A protocol that defines remote-notification authorization / registration methods
public protocol RemoteNotificationAuthorizationRequesting: class {
    func requestAuthorizationIfNeeded() -> Single<Void>
}

/// A protocol that defines remote-notification auth-status reading abilities
public protocol RemoteNotificationAuthorizationStatusProviding {
    var status: Single<UNAuthorizationStatus> { get }
    var isAuthorized: Single<Bool> { get }
}

extension RemoteNotificationAuthorizationStatusProviding {
    /// A `Single` that streams a boolean value indicating whether `status` is authorized
    /// A default implementation that depends on the status
    public var isAuthorized: Single<Bool> {
        status.map { $0 == .authorized }
    }
}
