// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
import Combine
import NetworkKit
import XCTest

class BitcoinTransactionCreationTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()

        cancellables = []
    }

    override func tearDownWithError() throws {
        cancellables = []

        try super.tearDownWithError()
    }

    func test_send_btc_success() throws {
        XCTSkip()

        // TODO: Coming in subsequent PR
    }
}
