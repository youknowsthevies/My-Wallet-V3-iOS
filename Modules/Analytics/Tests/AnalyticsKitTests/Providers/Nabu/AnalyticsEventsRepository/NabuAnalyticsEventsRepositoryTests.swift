// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import Mockingbird
import XCTest

@testable import AnalyticsKit

final class NabuAnalyticsEventsRepositoryTests: XCTestCase {
    var analyticsEventsRepository: NabuAnalyticsEventsRepository?

    let clientMock = mock(EventSendingAPI.self)
    let tokenProvider = { "token" }

    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        try super.setUpWithError()
        analyticsEventsRepository = NabuAnalyticsEventsRepository(
            client: clientMock,
            tokenProvider: tokenProvider
        )
    }

    override func tearDownWithError() throws {
        analyticsEventsRepository = nil
        try super.tearDownWithError()
    }

    func test_nabuAnalyticsEventsRepository_callsClientWithEventsAndToken() {
        let events = 1
        let token = "token"
        given(clientMock.publish(events: events, token: token)) ~> Empty().eraseToAnyPublisher()

        _ = analyticsEventsRepository?.publish(events: events)

        verify(clientMock.publish(events: events, token: token)).wasCalled(exactly(1))
    }
}
