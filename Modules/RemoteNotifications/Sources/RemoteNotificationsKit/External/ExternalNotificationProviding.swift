// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public enum ExternalNotificationProviderError: Error {
    case system(Error)
}

/// Aggregates any external service notification logic
public protocol ExternalNotificationProviding: AnyObject {
    /// Streams the token value if it exists and is valid (not empty).
    var token: AnyPublisher<String, RemoteNotification.TokenFetchError> { get }

    /// Let the messaging service know about the new token
    func didReceiveNewApnsToken(token: Data)

    /// Subscribes to a given topic so the client will be able to receive notifications for it.
    /// - Parameter topic: the topic that the client should subscribe to.
    /// - Returns: A publisher acknowledges the subscription.
    func subscribe(
        to topic: RemoteNotification.Topic
    ) -> AnyPublisher<Void, ExternalNotificationProviderError>
}
