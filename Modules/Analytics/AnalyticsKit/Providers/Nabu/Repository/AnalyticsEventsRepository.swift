// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

protocol NabuAnalyticsEventsRepositoryAPI {
    func publish<Events: Encodable>(
        events: Events
    ) -> AnyPublisher<Void, URLError>
}

final class NabuAnalyticsEventsRepository: NabuAnalyticsEventsRepositoryAPI {

    // MARK: - Private properties

    private let client: EventSendingAPI
    private let tokenRepository: TokenRepositoryAPI

    // MARK: - Setup

    init(client: EventSendingAPI,
         tokenRepository: TokenRepositoryAPI) {
        self.client = client
        self.tokenRepository = tokenRepository
    }

    // MARK: - AnalyticsEventsRepositoryAPI

    func publish<Events: Encodable>(
        events: Events
    ) -> AnyPublisher<Void, URLError> {
        client.publish(events: events, token: tokenRepository.token)
            .eraseToAnyPublisher()
    }
}
