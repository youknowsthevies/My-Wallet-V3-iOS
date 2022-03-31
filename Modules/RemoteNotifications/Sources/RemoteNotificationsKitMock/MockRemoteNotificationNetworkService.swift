// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
@testable import RemoteNotificationsKit

final class MockRemoteNotificationNetworkService: RemoteNotificationNetworkServicing {
    let expectedResult: Result<Void, PushNotificationError>

    init(expectedResult: Result<Void, PushNotificationError>) {
        self.expectedResult = expectedResult
    }

    func register(
        with deviceToken: String,
        sharedKeyProvider: SharedKeyRepositoryAPI,
        guidProvider: GuidRepositoryAPI
    ) -> AnyPublisher<Void, PushNotificationError> {
        expectedResult.publisher.eraseToAnyPublisher()
    }
}
