// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit
import PlatformKit

/// Publishes analytics events
protocol AnalyticsEventServiceAPI {
    
    /// Publishes the analytics events
    /// - Parameter events: the events payload
    func publish(events: EventsWrapper) -> AnyPublisher<Void, AnalyticsEventsDataError>
}

final class AnalyticsEventService: AnalyticsEventServiceAPI {
    
    // MARK: - Properties
    
    private let repository: AnalyticsEventsRepositoryAPI
    private let tokenProvider: TokenProviding

    // MARK: - Setup
    
    init(repository: AnalyticsEventsRepositoryAPI = resolve(),
         tokenProvider: TokenProviding = resolve()) {
        self.repository = repository
        self.tokenProvider = tokenProvider
    }
    
    // MARK: - AnalyticsEventServiceAPI
    
    func publish(events: EventsWrapper) -> AnyPublisher<Void, AnalyticsEventsDataError> {
        let repository = self.repository
        return tokenProvider.token
            .mapError()
            .flatMap { [repository] token -> AnyPublisher<Void, AnalyticsEventsDataError> in
                repository.publish(events: events, token: token)
            }
            .eraseToAnyPublisher()
    }
}
