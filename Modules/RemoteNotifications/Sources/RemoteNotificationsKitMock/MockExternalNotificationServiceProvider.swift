// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
@testable import RemoteNotificationsKit

final class MockExternalNotificationServiceProvider: ExternalNotificationProviding {

    var token: AnyPublisher<String, RemoteNotification.TokenFetchError> {
        expectedTokenResult.publisher.eraseToAnyPublisher()
    }

    private(set) var topics: [String] = []

    private let expectedTokenResult: Result<String, RemoteNotification.TokenFetchError>
    private let expectedTopicSubscriptionResult: Result<Void, ExternalNotificationProviderError>

    init(
        expectedTokenResult: Result<String, RemoteNotification.TokenFetchError>,
        expectedTopicSubscriptionResult: Result<Void, ExternalNotificationProviderError>
    ) {
        self.expectedTokenResult = expectedTokenResult
        self.expectedTopicSubscriptionResult = expectedTopicSubscriptionResult
    }

    func didReceiveNewApnsToken(token: Data) {}

    func subscribe(
        to topic: String
    ) -> AnyPublisher<Void, ExternalNotificationProviderError> {
        switch expectedTopicSubscriptionResult {
        case .success:
            topics.append(topic)
        case .failure:
            break
        }
        return expectedTopicSubscriptionResult
            .publisher
            .eraseToAnyPublisher()
    }
}
