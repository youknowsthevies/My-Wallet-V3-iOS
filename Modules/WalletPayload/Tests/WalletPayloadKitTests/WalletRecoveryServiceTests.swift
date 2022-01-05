// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MetadataKit
@testable import WalletPayloadKit

import Combine
import TestKit
import ToolKit
import XCTest

class WalletRecoveryServiceTests: XCTestCase {

    private let jsonV4 = Fixtures.loadJSONData(filename: "wallet.v4", in: .module)!

    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    // TODO: Dimitris to fix
    func test_wallet_recovery_returns_an_error_on_invalid_seed_phrase() throws {
        try XCTSkipIf(true, "not yet finalised")
        let walletHolder = WalletHolder()
        var walletCreatorCalled = false
        let walletCreator: WalletCreating = { blockchainWallet in
            walletCreatorCalled = true
            return Wallet(from: blockchainWallet)
        }

        let mockMetadata = MockMetadataService()

        let walletLogic = WalletLogic(
            holder: walletHolder,
            creator: walletCreator,
            metadata: mockMetadata
        )

        let walletRecoveryService = WalletRecoveryService(
            walletHolder: walletHolder,
            walletLogic: walletLogic
        )

        let expectation = expectation(description: "wallet holding")
        let invalidSeedPhrase = "this is invalid"

        walletRecoveryService.recover(from: invalidSeedPhrase)
            .sink { completion in
                XCTAssertEqual(completion, .failure(.recovery(.invalidSeedPhrase)))
                expectation.fulfill()
            } receiveValue: { _ in
                XCTFail("invalid seed phrase should fail")
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }
}
