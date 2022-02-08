// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import TestKit
import ToolKit
import XCTest

class WalletCreatorTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func test_wallet_creator_can_create_a_wallet() throws {
        try XCTSkipIf(true, "not yet finalized")

        let mockServerEntropy = MockServerEntropyRepository()
        mockServerEntropy.serverEntropyResult = .success("")
        let rngService = RNGService(
            serverEntropyRepository: mockServerEntropy,
            localEntropyProvider: { _ in .just(Data(hex: "")) }
        )
        let uuidProvider: UUIDProvider = { .just(("", "")) }
        let generateWalletMock: GenerateWalletProvider = { context in
            generateWallet(context: context)
        }
        let creator = WalletCreator(
            entropyService: rngService,
            uuidProvider: uuidProvider,
            generateWalletProvider: generateWalletMock
        )

        let email = "some@some.com"
        let password = "1234"
        let accountName = "Private Key Wallet"
        creator.createWallet(
            email: email,
            password: password,
            accountName: accountName
        )
        .sink { _ in
            XCTFail("not yet finalized")
        }
        .store(in: &cancellables)
    }
}
