// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import MetadataKit
@testable import WalletPayloadDataKit
@testable import WalletPayloadKit
@testable import WalletPayloadKitMock

import Combine
import TestKit
import ToolKit
import XCTest

class WalletRecoveryServiceTests: XCTestCase {

    private let jsonV4 = Fixtures.loadJSONData(filename: "wallet.v4", in: .module)!

    private var walletRepo: WalletRepo!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        walletRepo = WalletRepo(initialState: .empty)
        cancellables = []
    }

    func test_wallet_recovery_returns_an_error_on_invalid_seed_phrase() throws {
        let walletHolder = WalletHolder()
        var walletDecoderCalled = false
        let walletDecoder: WalletDecoderAPI = WalletDecoder()
        let decoder: WalletDecoding = { [walletDecoder] blockchainWallet in
            walletDecoderCalled = true
            return walletDecoder.createWallet(from: blockchainWallet)
        }

        let mockMetadata = MockMetadataService()

        let walletLogic = WalletLogic(
            holder: walletHolder,
            decoder: decoder,
            metadata: mockMetadata,
            notificationCenter: .default
        )

        var mockWalletPayloadClient = MockWalletPayloadClient(result: .failure(.from(.payloadError(.emptyData))))
        let walletPayloadRepository = WalletPayloadRepository(apiClient: mockWalletPayloadClient)
        let queue = DispatchQueue(label: "temp.recovery.queue")
        let walletRecoveryService = WalletRecoveryService(
            walletLogic: walletLogic,
            payloadCrypto: PayloadCrypto(cryptor: AESCryptor()),
            walletRepo: walletRepo,
            walletPayloadRepository: walletPayloadRepository,
            operationsQueue: queue
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

        XCTAssertFalse(walletDecoderCalled)
    }

    func test_wallet_recovery_returns_correct_value_on_success() throws {
        try XCTSkipIf(true, "not yet finalised")
        let walletHolder = WalletHolder()
        var walletDecoderCalled = false
        let walletDecoder: WalletDecoderAPI = WalletDecoder()
        let decoder: WalletDecoding = { [walletDecoder] blockchainWallet in
            walletDecoderCalled = true
            return walletDecoder.createWallet(from: blockchainWallet)
        }

        let mockMetadata = MockMetadataService()

        let walletLogic = WalletLogic(
            holder: walletHolder,
            decoder: decoder,
            metadata: mockMetadata,
            notificationCenter: .default
        )

        var mockWalletPayloadClient = MockWalletPayloadClient(result: .failure(.from(.payloadError(.emptyData))))
        let walletPayloadRepository = WalletPayloadRepository(apiClient: mockWalletPayloadClient)
        let queue = DispatchQueue(label: "temp.recovery.queue")
        let walletRecoveryService = WalletRecoveryService(
            walletLogic: walletLogic,
            payloadCrypto: PayloadCrypto(cryptor: AESCryptor()),
            walletRepo: walletRepo,
            walletPayloadRepository: walletPayloadRepository,
            operationsQueue: queue
        )

        let expectation = expectation(description: "wallet holding")
        let validSeedPhrase = "nuclear bunker sphaghetti monster dim sum sauce"
    }
}
