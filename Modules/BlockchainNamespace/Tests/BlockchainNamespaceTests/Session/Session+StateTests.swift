@testable import BlockchainNamespace
import Combine
import XCTest

final class SessionStateTests: XCTestCase {

    var app = App()
    var state: Session.State { app.state }

    override func setUp() {
        super.setUp()
        app = App()
    }

    func test_set_computed_value() throws {

        var iterator = [true, false].makeIterator()
        state.set(blockchain.user.is.tier.gold, to: { iterator.next()! })

        let a = try state.get(blockchain.user.is.tier.gold) as? Bool
        let b = try state.get(blockchain.user.is.tier.gold) as? Bool

        XCTAssertNotEqual(a, b)
    }

    func test_publisher_without_equatable_type_produces_duplicates() throws {

        let error = expectation(description: "did keyDoesNotExist error")
        let value = expectation(description: "did publish value")
        value.expectedFulfillmentCount = 2

        let it = state.publisher(for: blockchain.user.is.tier.gold)
            .sink { result in
                switch result {
                case .value:
                    value.fulfill()
                case .error(.keyDoesNotExist, _):
                    error.fulfill()
                case .error(let error, _):
                    XCTFail("Unexpected failure case \(error)")
                }
            }

        wait(for: [error], timeout: 1)

        state.set(blockchain.user.is.tier.gold, to: true)
        state.set(blockchain.user.is.tier.gold, to: true)

        wait(for: [value], timeout: 1)

        _ = it
    }

    func test_publisher_with_type() throws {

        let error = expectation(description: "did keyDoesNotExist error")
        let value = expectation(description: "did publish value")
        value.expectedFulfillmentCount = 2

        let it = app.publisher(for: blockchain.app.deep_link.url)
            .sink { result in
                switch result {
                case .value:
                    value.fulfill()
                case .error(.keyDoesNotExist, _):
                    error.fulfill()
                case .error(let error, _):
                    XCTFail("Unexpected failure case \(error)")
                }
            }

        state.set(blockchain.app.deep_link.url, to: URL(string: "https://www.blockchain.com")!)
        state.set(blockchain.app.deep_link.url, to: URL(string: "https://www.blockchain.com/app")!)

        wait(for: [value, error], timeout: 1)

        _ = it
    }

    func test_transaction_rollback() throws {

        enum Explicit: Error { case error }

        state.set(blockchain.user.is.tier.gold, to: true)

        state.transaction { state in
            state.set(blockchain.user.is.tier.gold, to: false)
            state.clear(blockchain.user.is.tier.gold)
            throw Explicit.error
        }

        try XCTAssertTrue(state.get(blockchain.user.is.tier.gold) as? Bool ?? false)
    }
}
