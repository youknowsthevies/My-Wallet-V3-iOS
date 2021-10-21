// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import WalletPayloadKit
import XCTest

class WalletFetcherTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_wallet_fetcher_is_able_to_fetch_using_password() throws {
        // skip test until it is finalized and working
        try XCTSkipIf(true)

        let walletFetcher = WalletFetcher()

        var receivedValue: Bool?
        var error: Error?
        let expectation = expectation(description: "wallet-fetching-expectation")

        walletFetcher.fetch(using: "a-password")
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failureError):
                    error = failureError
                }
                expectation.fulfill()
            } receiveValue: { value in
                receivedValue = value
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)

        XCTAssertTrue(receivedValue!)
        XCTAssertNil(error)
    }
}
