// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
@testable import MetadataDataKit
import MetadataHDWalletKit
@testable import MetadataKit
import NetworkKit
import TestKit
import ToolKit
import XCTest

final class MetadataServiceTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    private var subject: MetadataService!

    override func setUpWithError() throws {
        try super.setUpWithError()

        // subject = ...
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

        let fetchMetadataEntry: FetchMetadataEntry = { address in
            XCTAssertEqual(address, expectedAddress)
            fetchCalledWithCorrectAddressExpectation.fulfill()
            return .just(MetadataPayload.rootMetadataPayload)
        }

        let expectedState = environment.metadataState

        subject = MetadataService(
            loadMetadata: loadRemoteMetadata(
                fetchMetadataEntry: fetchMetadataEntry
            )
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
}
