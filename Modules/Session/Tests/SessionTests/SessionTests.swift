import XCTest
import Session

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
                case .success: value.fulfill()
                case .failure(.keyDoesNotExist): error.fulfill()
                case let .failure(error): XCTFail("Unexpected failure case \(error)")
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
                case .success: value.fulfill()
                case .failure(.keyDoesNotExist): error.fulfill()
                case let .failure(error): XCTFail("Unexpected failure case \(error)")
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

        try XCTAssertEqual(state.get("value"), true)

    }
}
