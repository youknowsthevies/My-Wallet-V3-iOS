// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import XCTest

extension Publisher {

    public func wait(
        description: String = #function,
        timeout: TimeInterval = 0.1,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Output {
        let promise = XCTestExpectation(description: description)
        var completion: Subscribers.Completion<Failure>?
        var output: Output?
        let cancellable = sink { _completion in
            completion = _completion
            promise.fulfill()
        } receiveValue: { _output in
            output = _output
        }
        XCTWaiter().wait(for: [promise], timeout: timeout)
        cancellable.cancel()
        switch try XCTUnwrap(completion, file: file, line: line) {
        case .failure(let error):
            throw error
        case .finished:
            return try XCTUnwrap(output, file: file, line: line)
        }
    }
}
