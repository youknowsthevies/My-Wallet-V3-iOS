// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import TestKit
import ToolKit
import XCTest

class RNGServiceTests: XCTestCase {

    let serverBuffer = "0000000000000000000000000000000000000000000000000000000000000010"
    let zerosServerBuffer = "0000000000000000000000000000000000000000000000000000000000000000"
    let shortServerBuffer = "0000000000000000000000000000000001"

    let xorBuffer = Data(hex: "0000000000000000000000000000000000000000000000000000000000000011")
    let oneLocalBuffer = Data(hex: "0000000000000000000000000000000000000000000000000000000000000001")
    let zerosLocalBuffer = Data(hex: "0000000000000000000000000000000000000000000000000000000000000000")

    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    // MARK: - generate entropy

    func test_generate_entropy() {
        let mockServerEntropy = MockServerEntropyRepository()
        let localEntropy = { (_: EntropyBytes) -> AnyPublisher<Data, RNGEntropyError> in
            .just(self.oneLocalBuffer)
        }
        let service = RNGService(
            serverEntropyRepository: mockServerEntropy,
            localEntropyProvider: localEntropy,
            combineEntropyParsing: combineEntropies
        )

        let expectation = expectation(description: "")

        mockServerEntropy.serverEntropyResult = .success(
            "0000000000000000000000000000000000000000000000000000000000000010"
        )

        service.generateEntropy(bytes: .default, format: .hex)
            .sink(receiveCompletion: { completion in
                guard case .failure(let error) = completion else {
                    return
                }
                XCTFail("shouldn't not occur: \(error)")
            }, receiveValue: { [xorBuffer] value in
                XCTAssertEqual(value, xorBuffer)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }

    func test_generate_entropy_fails_on_server_zeros() {
        let mockServerEntropy = MockServerEntropyRepository()
        let localEntropy = { (_: EntropyBytes) -> AnyPublisher<Data, RNGEntropyError> in
            .just(self.oneLocalBuffer)
        }
        let service = RNGService(
            serverEntropyRepository: mockServerEntropy,
            localEntropyProvider: localEntropy,
            combineEntropyParsing: combineEntropies
        )

        let expectation = expectation(description: "")

        mockServerEntropy.serverEntropyResult = .success(zerosServerBuffer)

        service.generateEntropy(bytes: .default, format: .hex)
            .sink(receiveCompletion: { completion in
                guard case .failure(let error) = completion else {
                    return
                }
                XCTAssertEqual(error, .parsingFailed(.serverEntropyInvalid))
                expectation.fulfill()
            }, receiveValue: { _ in
                XCTFail("shouldn't not occur")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }

    func test_generate_entropy_fails_on_local_zeros() {
        let mockServerEntropy = MockServerEntropyRepository()
        let localEntropy = { (_: EntropyBytes) -> AnyPublisher<Data, RNGEntropyError> in
            .just(self.zerosLocalBuffer)
        }
        let service = RNGService(
            serverEntropyRepository: mockServerEntropy,
            localEntropyProvider: localEntropy,
            combineEntropyParsing: combineEntropies
        )

        let expectation = expectation(description: "")

        mockServerEntropy.serverEntropyResult = .success(serverBuffer)

        service.generateEntropy(bytes: .default, format: .hex)
            .sink(receiveCompletion: { completion in
                guard case .failure(let error) = completion else {
                    return
                }
                XCTAssertEqual(error, .parsingFailed(.localEntropyInvalid))
                expectation.fulfill()
            }, receiveValue: { _ in
                XCTFail("shouldn't not occur")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }

    // MARK: - entropy provider

    func test_entropy_provider_generates_correct_value() {
        let count = 32

        let expectation = expectation(description: "should provider correct value")

        provideLocalEntropy(bytes: .custom(count))
            .sink { completion in
                guard case .failure = completion else {
                    return
                }
                XCTFail("should provide a value")
            } receiveValue: { value in
                XCTAssertFalse(value.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }

    // MARK: - urandom method

    func test_secureRandomNumberGenerator_generates_correct_value() {
        let count = 32
        switch secureRandomNumberGenerator(count: count) {
        case .failure:
            XCTFail("should provide a random number")
        case .success(let value):
            XCTAssertFalse(value.isEmpty)
            XCTAssertEqual(value.count, count)
        }
    }

    // MARK: - xor method

    func test_xor_method_provides_correct_output() {
        let left = Data(hex: "a123456c")
        let right = Data(hex: "ff0123cd")
        let output = Data(hex: "5e2266a1")
        XCTAssertEqual(
            xor(left: left, right: right),
            output
        )
    }

    func test_xor_method_returns_the_common_count() {
        let left = Data(hex: "a123")
        let right = Data(hex: "ff0123cd")
        let output = Data(hex: "5e22")
        XCTAssertEqual(
            xor(left: left, right: right),
            output
        )
    }
}
