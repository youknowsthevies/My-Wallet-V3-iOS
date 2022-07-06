// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureTransactionDomain
import TestKit
import XCTest

final class QuotesEngineTest: XCTestCase {
    var sut: QuotesEngine!
    var expirationTimer: PassthroughSubject<Void, Never>!

    override func setUp() {
        super.setUp()
        expirationTimer = .init()
        sut = QuotesEngine(
            repository: OrderQuoteRepositoryMock(),
            timer: { _ in self.expirationTimer.eraseToAnyPublisher() }
        )
    }

    override func tearDown() {
        expirationTimer = nil
        sut = nil
        super.tearDown()
    }

    func test_emitsData_immediatelyAfterStartPolling() throws {
        let e = expectation(description: "Returns Quote")
        e.expectedFulfillmentCount = 1

        let cancellable = sut.quotePublisher
            .sink(receiveValue: { _ in
                e.fulfill()
            })

        sut.startPollingRate(direction: .onChain, pair: .btc_eth)

        wait(for: [e], timeout: 5)
        cancellable.cancel()
    }

    func test_emitsData_immediatelyAfterAmountUpdate() throws {
        let e = expectation(description: "Returns Quote")
        e.expectedFulfillmentCount = 2

        let cancellable = sut.quotePublisher
            .sink(receiveValue: { _ in
                e.fulfill()
            })

        sut.startPollingRate(direction: .onChain, pair: .btc_eth)
        sut.update(amount: 100)

        wait(for: [e], timeout: 5)
        cancellable.cancel()
    }

    func test_emitsData_afterQuoteExpiratonStartPolling() throws {
        let e = expectation(description: "Returns Quote")
        e.expectedFulfillmentCount = 3

        let cancellable = sut.quotePublisher
            .sink(receiveValue: { _ in
                e.fulfill()
            })

        sut.startPollingRate(direction: .onChain, pair: .btc_eth)

        expirationTimer.send(())
        expirationTimer.send(())

        wait(for: [e], timeout: 5)
        cancellable.cancel()
    }

    func test_stopsEmittingData_afterStopSignal() throws {
        let e = expectation(description: "Returns Quote")
        e.expectedFulfillmentCount = 1

        let cancellable = sut.quotePublisher
            .sink(receiveValue: { _ in
                e.fulfill()
            })

        sut.startPollingRate(direction: .onChain, pair: .btc_eth)
        sut.stop()
        sut.update(amount: 100)
        expirationTimer.send(())

        wait(for: [e], timeout: 5)
        cancellable.cancel()
    }
}
