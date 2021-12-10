// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
@testable import MetadataDataKit
import MetadataHDWalletKit
@testable import MetadataKit
import TestKit
import ToolKit
import XCTest

final class FetchEntryTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()

        cancellables = []
    }

    override func tearDownWithError() throws {
        cancellables = nil

        try super.tearDownWithError()
    }

    func test_fetchEntry_success() throws {

        // Arrange
        let successfullyFetchedExpectation = expectation(
            description: "The entry was successfully fetched"
        )

        let fetchCalledWithCorrectAddressExpectation = expectation(
            description: "The correct node was passed in"
        )

        let environment = TestEnvironment()

        let expectedAddress = "129GLwNB2EbNRrGMuNSRh9PM83xU2Mpn81"

        let expectedEntry = EthereumEntryPayload.entry

        let fetchMetadataEntry: FetchMetadataEntry = { address in
            XCTAssertEqual(address, expectedAddress)
            fetchCalledWithCorrectAddressExpectation.fulfill()
            return .just(MetadataPayload.ethereumMetadataEntryPayload)
        }

        let subject = provideFetchEntry(fetch: fetchMetadataEntry)

        let entryType = EntryType.ethereum
        let metadataNodes = environment.metadataState.metadataNodes

        // Act
        subject(entryType, metadataNodes)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
            }, receiveValue: { [successfullyFetchedExpectation] entry in
                // swiftlint:disable:next force_try
                let encoded = try! JSONDecoder().decode(
                    EthereumEntryPayload.self,
                    from: Data(entry.utf8)
                )
                XCTAssertEqual(encoded, expectedEntry)
                successfullyFetchedExpectation.fulfill()
            })
            .store(in: &cancellables)

        // Assert
        wait(
            for: [
                fetchCalledWithCorrectAddressExpectation,
                successfullyFetchedExpectation
            ],
            timeout: 10.0
        )
    }

    func test_fetchEntry_notYetCreated() throws {

        // Arrange
        let entryNotYetCreatedErrorReceivedExpectation = expectation(
            description: "The notYetCreated error received"
        )

        let fetchCalledWithCorrectAddressExpectation = expectation(
            description: "The correct node was passed in"
        )

        let environment = TestEnvironment()

        let expectedAddress = "129GLwNB2EbNRrGMuNSRh9PM83xU2Mpn81"

        let fetchMetadataEntry: FetchMetadataEntry = { address in
            XCTAssertEqual(address, expectedAddress)
            fetchCalledWithCorrectAddressExpectation.fulfill()
            return .failure(.notFoundError)
        }

        let expectedError: MetadataFetchError = .loadMetadataError(.notYetCreated)

        let subject = provideFetchEntry(fetch: fetchMetadataEntry)

        let entryType = EntryType.ethereum
        let metadataNodes = environment.metadataState.metadataNodes

        // Act
        subject(entryType, metadataNodes)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTAssertEqual(error, expectedError)
                    entryNotYetCreatedErrorReceivedExpectation.fulfill()
                case .finished:
                    break
                }
            }, receiveValue: { _ in
                XCTFail("No value should be received")
            })
            .store(in: &cancellables)

        // Assert
        wait(
            for: [
                entryNotYetCreatedErrorReceivedExpectation,
                fetchCalledWithCorrectAddressExpectation
            ],
            timeout: 10.0
        )
    }
}
