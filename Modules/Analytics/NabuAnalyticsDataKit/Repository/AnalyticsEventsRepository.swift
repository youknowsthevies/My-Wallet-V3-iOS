// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NabuAnalyticsKit
import NetworkKit

final class AnalyticsEventsRepository: AnalyticsEventsRepositoryAPI {

    // MARK: - Private properties

    private let client: EventSendingAPI

    // MARK: - Setup

    init(client: EventSendingAPI = resolve()) {
        self.client = client
    }

    // MARK: - AnalyticsEventsRepositoryAPI

    func publish<Events: Encodable>(
        events: Events,
        token: String?
    ) -> AnyPublisher<Void, AnalyticsEventsDataError> {
        client.publish(events: events, token: token)
            .mapError(AnalyticsEventsDataError.network)
            .eraseToAnyPublisher()
    }
}
