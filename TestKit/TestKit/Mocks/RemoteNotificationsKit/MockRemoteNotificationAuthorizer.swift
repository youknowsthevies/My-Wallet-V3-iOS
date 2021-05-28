// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import RemoteNotificationsKit
import RxSwift
import UserNotifications

final class MockRemoteNotificationAuthorizer {
    private let expectedAuthorizationStatus: UNAuthorizationStatus
    private let authorizationRequestExpectedStatus: Result<Void, RemoteNotificationAuthorizer.ServiceError>

    init(expectedAuthorizationStatus: UNAuthorizationStatus,
         authorizationRequestExpectedStatus: Result<Void, RemoteNotificationAuthorizer.ServiceError>) {
        self.expectedAuthorizationStatus = expectedAuthorizationStatus
        self.authorizationRequestExpectedStatus = authorizationRequestExpectedStatus
    }
}

// MARK: - RemoteNotificationAuthorizationStatusProviding

extension MockRemoteNotificationAuthorizer: RemoteNotificationAuthorizationStatusProviding {
    var status: Single<UNAuthorizationStatus> {
        .just(expectedAuthorizationStatus)
    }
}

// MARK: - RemoteNotificationRegistering

extension MockRemoteNotificationAuthorizer: RemoteNotificationRegistering {
    func registerForRemoteNotificationsIfAuthorized() -> Single<Void> {
        if expectedAuthorizationStatus == .authorized {
            return .just(())
        } else {
            return .error(RemoteNotificationAuthorizer.ServiceError.unauthorizedStatus)
        }
    }
}

// MARK: - RemoteNotificationAuthorizing

extension MockRemoteNotificationAuthorizer: RemoteNotificationAuthorizationRequesting {
    func requestAuthorizationIfNeeded() -> Single<Void> {
        authorizationRequestExpectedStatus.single
    }
}
