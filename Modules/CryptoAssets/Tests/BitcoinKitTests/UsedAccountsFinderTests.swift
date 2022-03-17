// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
@testable import BitcoinKit
@testable import BitcoinKitMock

import Combine
import NetworkError
import TestKit
import WalletPayloadKit
import XCTest

class UsedAccountsFinderTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!
    private let queue = DispatchQueue(label: "used.accounts.finder.queue")

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_find_used_accounts_with_no_transaction_outputs_zero() {

        let mockClient = APIClientMock()
        let finder = UsedAccountsFinder(client: mockClient)

        // with no transactions
        let addresses = (0..<10).map { index in
            BitcoinChainAddressResponse(
                accountIndex: index,
                address: "a_\(index)",
                changeIndex: 0,
                finalBalance: 0,
                nTx: 0,
                totalReceived: 0,
                totalSent: 0
            )
        }

        mockClient.multiAddressResult = .success(
            BitcoinMultiAddressResponse(
                addresses: addresses,
                transactions: [],
                latestBlockHeight: 0
            )
        )

        let retriever: XpubRetriever = { _, index in
            "a_\(index)"
        }

        let result = finder.findUsedAccounts(
            batch: 10,
            xpubRetriever: retriever
        )

        let expectation = expectation(description: "should provide correct total accounts")

        result.sink(
            receiveCompletion: { completion in
                guard case .failure = completion else {
                    return
                }
                XCTFail("should provide total account numbers")
            },
            receiveValue: { value in
                XCTAssertEqual(value, 0)
                expectation.fulfill()
            }
        )
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }

    func test_find_used_accounts_with_5_transaction_outputs_5() {

        let mockClient = APIClientMock()
        let finder = UsedAccountsFinder(client: mockClient)

        // with no transactions
        let addresses = (0..<10).map { index in
            BitcoinChainAddressResponse(
                accountIndex: index,
                address: "a_\(index)",
                changeIndex: 0,
                finalBalance: 0,
                nTx: (index >= 5) ? 0 : 1,
                totalReceived: 0,
                totalSent: 0
            )
        }

        mockClient.multiAddressResult = .success(
            BitcoinMultiAddressResponse(
                addresses: addresses,
                transactions: [],
                latestBlockHeight: 0
            )
        )

        let retriever: XpubRetriever = { _, index in
            "a_\(index)"
        }

        let result = finder.findUsedAccounts(
            batch: 10,
            xpubRetriever: retriever
        )

        let expectation = expectation(description: "should provide correct total accounts")

        result.sink(
            receiveCompletion: { completion in
                guard case .failure = completion else {
                    return
                }
                XCTFail("should provide total account numbers")
            },
            receiveValue: { value in
                XCTAssertEqual(value, 5)
                expectation.fulfill()
            }
        )
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }

    func test_find_used_accounts_with_10_transaction_outputs_10() {

        let mockClient = APIClientMock()
        let finder = UsedAccountsFinder(client: mockClient)

        // with no transactions
        let addresses = (0..<10).map { index in
            BitcoinChainAddressResponse(
                accountIndex: index,
                address: "a_\(index)",
                changeIndex: 0,
                finalBalance: 0,
                nTx: 1,
                totalReceived: 0,
                totalSent: 0
            )
        }

        mockClient.multiAddressResult = .success(
            BitcoinMultiAddressResponse(
                addresses: addresses,
                transactions: [],
                latestBlockHeight: 0
            )
        )

        let retriever: XpubRetriever = { _, index in
            "a_\(index)"
        }

        let result = finder.findUsedAccounts(
            batch: 10,
            xpubRetriever: retriever
        )

        let expectation = expectation(description: "should provide correct total accounts")

        result.sink(
            receiveCompletion: { completion in
                guard case .failure = completion else {
                    return
                }
                XCTFail("should provide total account numbers")
            },
            receiveValue: { value in
                XCTAssertEqual(value, 10)
                expectation.fulfill()
            }
        )
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }

    func test_find_used_accounts_with_12_transaction_outputs_12() {

        let mockClient = APIClientMock()
        let finder = UsedAccountsFinder(client: mockClient)

        // with no transactions
        let addresses = (0..<12).map { index in
            BitcoinChainAddressResponse(
                accountIndex: index,
                address: "a_\(index)",
                changeIndex: 0,
                finalBalance: 0,
                nTx: 1,
                totalReceived: 0,
                totalSent: 0
            )
        }

        mockClient.multiAddressResult = .success(
            BitcoinMultiAddressResponse(
                addresses: addresses,
                transactions: [],
                latestBlockHeight: 0
            )
        )

        let retriever: XpubRetriever = { _, index in
            "a_\(index)"
        }

        let result = finder.findUsedAccounts(
            batch: 10,
            xpubRetriever: retriever
        )

        let expectation = expectation(description: "should provide correct total accounts")

        result.sink(
            receiveCompletion: { completion in
                guard case .failure = completion else {
                    return
                }
                XCTFail("should provide total account numbers")
            },
            receiveValue: { value in
                XCTAssertEqual(value, 12)
                expectation.fulfill()
            }
        )
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }

    func test_find_used_accounts_returns_failure_on_network_error() {

        let mockClient = APIClientMock()
        let finder = UsedAccountsFinder(client: mockClient)

        // with no transactions
        mockClient.multiAddressResult = .failure(.serverError(.badResponse))

        let retriever: XpubRetriever = { _, index in
            "a_\(index)"
        }

        let result = finder.findUsedAccounts(
            batch: 10,
            xpubRetriever: retriever
        )

        let expectation = expectation(description: "should error")

        result.sink(
            receiveCompletion: { completion in
                guard case .failure = completion else {
                    return
                }
                expectation.fulfill()
            },
            receiveValue: { _ in
                XCTFail("should have failed due to network error")
            }
        )
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }
}
