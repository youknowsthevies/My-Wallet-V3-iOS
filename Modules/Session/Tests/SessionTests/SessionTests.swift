// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Session
import XCTest

final class SessionTests: XCTestCase {

    var state: Session.State<String>!

    override func setUp() {
        super.setUp()
        state = .init()
    }

    func test_set_computed_value() throws {

        var iterator = [1, 2].makeIterator()
        state.set("computed", to: { iterator.next()! })

        let a: Int = try state.get("computed")
        let b: Int = try state.get("computed")

        XCTAssertNotEqual(a, b)
    }

    func test_publisher_without_equatable_type_produces_duplicates() throws {

        let error = expectation(description: "did keyDoesNotExist error")
        let value = expectation(description: "did publish value")
        value.expectedFulfillmentCount = 2

        let it = state.publisher(for: "published")
            .sink { result in
                switch result {
                case .success:
                    value.fulfill()
                case .failure(.keyDoesNotExist):
                    error.fulfill()
                case .failure(let error):
                    XCTFail("Unexpected failure case \(error)")
                }
            }

        state.set("published", to: true)
        state.set("published", to: true)

        wait(for: [value, error], timeout: 1)

        _ = it
    }

    func test_publisher_with_type() throws {

        let error = expectation(description: "did keyDoesNotExist error")
        let value = expectation(description: "did publish value")

        let it = state.publisher(for: "published", as: Bool.self)
            .sink { result in
                switch result {
                case .success:
                    value.fulfill()
                case .failure(.keyDoesNotExist):
                    error.fulfill()
                case .failure(let error):
                    XCTFail("Unexpected failure case \(error)")
                }
            }

        state.set("published", to: true)
        state.set("published", to: true)

        wait(for: [value, error], timeout: 1)

        _ = it
    }

    func test_transaction_rollback() throws {

        enum Explicit: Error { case error }

        state.set("value", to: true)

        state.transaction { state in
            state.set("value", to: false)
            state.clear("value")
            throw Explicit.error
        }

        try XCTAssertTrue(state.get("value"))
    }

    func test_concurrency() throws {

        let iterations = 5000

        DispatchQueue.concurrentPerform(iterations: iterations) { i in
            state.set("\(i % 10)", to: i % 10)
        }

        DispatchQueue.concurrentPerform(iterations: iterations) { i in
            do {
                let value: Int = try state.get("\(i % 10)")
                XCTAssertEqual(value, i % 10)
            } catch {
                XCTFail("\(i) @ \(i % 10) has a missing value")
            }
        }

        DispatchQueue.concurrentPerform(iterations: iterations) { i in
            state.clear("\(i % 10)")
        }

        DispatchQueue.concurrentPerform(iterations: iterations) { i in
            XCTAssertFalse(state.contains("\(i % 10)"))
        }
    }

    func test_stress() {
        DispatchQueue.concurrentPerform(iterations: 10_000) { _ in
            var rng: Int { Int.random(in: 0...100) }
            state.set("\(rng)", to: rng)
            _ = state.contains("\(rng)")
            state.clear("\(rng)")
            _ = try? state.get("\(rng)")
            state.transaction { state in
                state.set("\(rng)", to: rng)
                state.clear("\(rng)")
            }
            _ = state.publisher(for: "\(rng)")
        }
    }
}
