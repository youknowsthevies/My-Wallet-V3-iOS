// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import XCTest

@testable import KeychainKit

class KeychainReaderTests: XCTestCase {

    func test_reader_can_read_a_value_from_the_keychain() {
        // given a successful read
        let data = "value".data(using: .utf8)
        let coreReader: CoreKeychainReader = { _ in
            ReadOutput(
                object: data as AnyObject,
                status: errSecSuccess
            )
        }
        let reader = KeychainReader(
            queryProvider: GenericPasswordQuery(service: "some-service"),
            coreReader: coreReader
        )

        switch reader.read(for: "some-key") {
        case .success(let value):
            XCTAssertEqual(value, data)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func test_reader_should_return_correct_failure_when_item_is_not_found() {
        // given a read that returns item not found
        let coreReader: CoreKeychainReader = { _ in
            ReadOutput(
                object: nil,
                status: errSecItemNotFound
            )
        }

        let reader = KeychainReader(
            queryProvider: GenericPasswordQuery(service: "some-service"),
            coreReader: coreReader
        )

        switch reader.read(for: "some-key") {
        case .success:
            XCTFail("should not succeed")
        case .failure(let error):
            XCTAssertEqual(error, .itemNotFound(account: "some-key"))
        }
    }

    func test_reader_should_return_correct_failure_when_read_return_no_success() {
        // given a read that returns an error
        let coreReader: CoreKeychainReader = { _ in
            ReadOutput(
                object: nil,
                status: errSecBadReq
            )
        }

        let reader = KeychainReader(
            queryProvider: GenericPasswordQuery(service: "some-service"),
            coreReader: coreReader
        )

        switch reader.read(for: "some-key") {
        case .success:
            XCTFail("should not succeed")
        case .failure(let error):
            XCTAssertEqual(error, .readFailed(account: "some-key", status: errSecBadReq))
        }
    }

    func test_reader_should_return_correct_failure_when_data_is_nil_but_query_succeeded() {
        // given a read that returns a nil object but a query was successful
        let coreReader: CoreKeychainReader = { _ in
            ReadOutput(
                object: nil,
                status: errSecSuccess
            )
        }

        let reader = KeychainReader(
            queryProvider: GenericPasswordQuery(service: "some-service"),
            coreReader: coreReader
        )

        switch reader.read(for: "some-key") {
        case .success:
            XCTFail("should not succeed")
        case .failure(let error):
            XCTAssertEqual(error, .dataCorrupted(account: "some-key"))
        }
    }
}
