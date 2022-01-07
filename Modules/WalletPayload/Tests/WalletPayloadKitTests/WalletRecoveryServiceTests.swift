// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MetadataKit
@testable import WalletPayloadDataKit
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
    func test_wallet_recovery_returns_an_error_on_invalid_mnemonic() throws {
        try XCTSkipIf(true, "not yet finalised")
        let walletHolder = WalletHolder()
        var walletCreatorCalled = false
        let walletCreator: WalletCreatorAPI = WalletCreator()
        let creator: WalletCreating = { [walletCreator] blockchainWallet in
            walletCreatorCalled = true
            return walletCreator.createWallet(from: blockchainWallet)
        }

        let mockMetadata = MockMetadataService()

        let walletLogic = WalletLogic(
            holder: walletHolder,
            creator: creator,
            metadata: mockMetadata
        )

        let walletRecoveryService = WalletRecoveryService(
            walletHolder: walletHolder,
            walletLogic: walletLogic
        )

        let expectation = expectation(description: "wallet holding")
        let invalidMnemonic = "this is invalid"

        walletRecoveryService.recover(from: invalidMnemonic)
            .sink { completion in
                XCTAssertEqual(completion, .failure(.recovery(.invalidMnemonic)))
                expectation.fulfill()
            } receiveValue: { _ in
                XCTFail("invalid seed phrase should fail")
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)

        XCTAssertTrue(walletCreatorCalled)
    }
}
