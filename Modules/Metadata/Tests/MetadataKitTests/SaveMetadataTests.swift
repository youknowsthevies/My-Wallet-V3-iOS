// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
@testable import MetadataDataKit
@testable import MetadataKit
import TestKit
import ToolKit
import XCTest

final class SaveMetadataTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()

        cancellables = []
    }

    override func tearDownWithError() throws {
        cancellables = nil

        try super.tearDownWithError()
    }

    func test_save() throws {

        let successfullySavedExpectation = expectation(
            description: "The entry was successfully saved"
        )

        let validParametersSavedExpectation = expectation(
            description: "The correct parameters were passed in to the save function"
        )

        let environment = TestEnvironment()

        let metadataState = environment.metadataState

        let expectedAddress = "129GLwNB2EbNRrGMuNSRh9PM83xU2Mpn81"

        let type = EntryType.ethereum

        let fetch: FetchMetadataEntry = { address in
            XCTAssertEqual(address, expectedAddress)
            guard let response = MetadataResponse.fetchMagicResponse(for: address) else {
                return .failure(NetworkError.notFoundError)
            }
            return AnyPublisher<MetadataResponse, NetworkError>.just(response)
                .map(MetadataPayload.init(from:))
                .eraseToAnyPublisher()
        }

        let put: PutMetadataEntry = { address, body in
            XCTAssertEqual(address, expectedAddress)
            XCTAssertEqual(body.version, 1)
            XCTAssertEqual(
                body.prevMagicHash,
                "3abd6051e3dfdc68c54ed63c12eb1abab11eaa7caee30cf56e451b87fa8d75f1"
            )
            XCTAssertEqual(body.typeId, Int(type.rawValue))

            let key = metadataState
                .metadataNodes
                .metadataNode

            return MetadataNode
                .from(
                    metaDataHDNode: key,
                    metadataDerivation: MetadataDerivation(),
                    for: type
                )
                .publisher
                .eraseToAnyPublisher()
                .replaceError(with: NetworkError.notFoundError)
                .flatMap { metadataNode -> AnyPublisher<Void, NetworkError> in
                    decryptMetadata(
                        metadata: metadataNode,
                        payload: body.payload
                    )
                    .publisher
                    .replaceError(with: NetworkError.notFoundError)
                    .mapToVoid()
                }
                .handleEvents(receiveOutput: { _ in
                    validParametersSavedExpectation.fulfill()
                })
                .eraseToAnyPublisher()
        }

        let payloadJson = try EthereumEntryPayload.entry
            .encodeToJSONString()
            .get()
        let nodes = metadataState.metadataNodes

        save(
            input: .init(
                payloadJson: payloadJson,
                type: type,
                nodes: nodes
            ),
            putMetadata: put,
            fetchMetadata: fetch
        )
        .sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                XCTFail(error.localizedDescription)
            case .finished:
                break
            }
        }, receiveValue: { [successfullySavedExpectation] _ in
            successfullySavedExpectation.fulfill()
        })
        .store(in: &cancellables)

        wait(
            for: [
                successfullySavedExpectation,
                validParametersSavedExpectation
            ],
            timeout: 20.0
        )
    }
}
