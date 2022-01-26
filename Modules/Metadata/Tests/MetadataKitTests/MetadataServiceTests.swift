// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import MetadataDataKit
@testable import MetadataKit
import NetworkKit
import TestKit
import ToolKit
import XCTest

final class MetadataServiceTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    private var subject: MetadataServiceAPI!

    override func setUpWithError() throws {
        try super.setUpWithError()

        cancellables = []
    }

    override func tearDownWithError() throws {
        subject = nil
        cancellables = nil

        try super.tearDownWithError()
    }

    func test_initialize() throws {

        let environment = TestEnvironment()

        let initializedExpecation = expectation(
            description: "Metadata was successfully initialized"
        )

        let fetchCalledWithCorrectAddressExpectation = expectation(
            description: "Fetch was called with the correct address"
        )

        let expectedAddress = "12TMDMri1VSjbBw8WJvHmFpvpxzTJe7EhU"

        let fetch: FetchMetadataEntry = { address in
            XCTAssertEqual(address, expectedAddress)
            fetchCalledWithCorrectAddressExpectation.fulfill()
            return .just(MetadataPayload.rootMetadataPayload)
        }

        let put: PutMetadataEntry = { _, _ in
            XCTFail("Put should not be called")
            return .just(())
        }

        let expectedState = environment.metadataState

        subject = MetadataService(
            initialize: provideInitialize(
                fetch: fetch,
                put: put
            ),
            fetchEntry: provideFetchEntry(fetch: fetch),
            saveEntry: provideSave(fetch: fetch, put: put)
        )

        subject
            .initialize(
                credentials: environment.credentials,
                masterKey: environment.masterKey,
                payloadIsDoubleEncrypted: false
            )
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
            }, receiveValue: { [initializedExpecation] metadataState in
                XCTAssertEqual(metadataState, expectedState)
                initializedExpecation.fulfill()
            })
            .store(in: &cancellables)

        wait(
            for: [
                initializedExpecation,
                fetchCalledWithCorrectAddressExpectation
            ],
            timeout: 10.0
        )
    }

    func test_fetch() throws {

        let successfullyFetchedExpectation = expectation(
            description: "The entry was successfully fetched"
        )

        let fetchCalledWithCorrectAddressExpectation = expectation(
            description: "Fetch was called with the correct address"
        )

        let expectedAddress = "129GLwNB2EbNRrGMuNSRh9PM83xU2Mpn81"

        let fetch: FetchMetadataEntry = { address in
            XCTAssertEqual(address, expectedAddress)
            fetchCalledWithCorrectAddressExpectation.fulfill()
            return .just(MetadataPayload.ethereumMetadataEntryPayload)
        }

        let put: PutMetadataEntry = { _, _ in
            XCTFail("Put should not be called")
            return .just(())
        }

        let environment = TestEnvironment()

        let metadataState = environment.metadataState

        let expectedEntryPayload = EthereumEntryPayload.entry

        subject = MetadataService(
            initialize: provideInitialize(
                fetch: fetch,
                put: put
            ),
            fetchEntry: provideFetchEntry(fetch: fetch),
            saveEntry: provideSave(fetch: fetch, put: put)
        )

        subject
            .fetchEntry(with: metadataState)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
            }, receiveValue: { [successfullyFetchedExpectation] (entry: EthereumEntryPayload) in
                XCTAssertEqual(entry, expectedEntryPayload)
                successfullyFetchedExpectation.fulfill()
            })
            .store(in: &cancellables)

        wait(
            for: [
                fetchCalledWithCorrectAddressExpectation,
                successfullyFetchedExpectation
            ],
            timeout: 10.0
        )
    }
}
