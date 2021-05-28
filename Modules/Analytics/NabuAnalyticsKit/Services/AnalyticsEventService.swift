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

    private let eventsRepository: AnalyticsEventsRepositoryAPI
    private let tokenRepository: TokenRepositoryAPI

    // MARK: - Setup

    init(repository: AnalyticsEventsRepositoryAPI = resolve(),
         tokenProvider: TokenRepositoryAPI = resolve()) {
        self.eventsRepository = repository
        self.tokenRepository = tokenProvider
    }

    // MARK: - AnalyticsEventServiceAPI

    func publish(events: EventsWrapper) -> AnyPublisher<Void, AnalyticsEventsDataError> {
        tokenRepository.token
            .mapError()
            .flatMap { [eventsRepository] token -> AnyPublisher<Void, AnalyticsEventsDataError> in
                eventsRepository.publish(events: events, token: token)
            }
            .eraseToAnyPublisher()
    }
}
