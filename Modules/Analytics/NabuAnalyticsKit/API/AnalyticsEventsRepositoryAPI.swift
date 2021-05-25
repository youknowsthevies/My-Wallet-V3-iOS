// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

public enum AnalyticsEventsDataError: Error {

    /// A network error
    case network(NetworkError)
}

/// Publishes the analytics events to the store
public protocol AnalyticsEventsRepositoryAPI {

    /// Publishes the analytics events to the store
    /// - Parameters:
    ///   - events: the `Encodable` analytics event payload
    ///   - token: the bearer token used to authenticate the request
    func publish<Events: Encodable>(
        events: Events,
        token: String?
    ) -> AnyPublisher<Void, AnalyticsEventsDataError>
}
