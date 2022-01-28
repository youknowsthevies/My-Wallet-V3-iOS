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
        let mockServerEntropy = MockServerEntropyRepository()
        mockServerEntropy.serverEntropyResult = .success("00000000000000000000000000000011")
        let rngService = RNGService(
            serverEntropyRepository: mockServerEntropy,
            localEntropyProvider: { _ in .just(Data(hex: "00000000000000000000000000000001")) }
        )
        var uuidProviderCalled = false
        let uuidProvider: UUIDProvider = {
            uuidProviderCalled = true
            return .just(("", ""))
        }
        var generateWalletCalled = false
        let generateWalletMock: GenerateWalletProvider = { context in
            generateWalletCalled = true
            return generateWallet(context: context)
        }
        var generateWrapperCalled = false
        let generateWrapperMock: GenerateWrapperProvider = { wallet, language, version in
            generateWrapperCalled = true
            return generateWrapper(wallet: wallet, language: language, version: version)
        }
        let mockCreateRepository = MockCreateWalletRepository()
        mockCreateRepository.createWallerResult = .just(())
        let creator = WalletCreator(
            entropyService: rngService,
            walletEncoder: WalletEncoder(),
            encryptor: PayloadCrypto(cryptor: AESCryptor()),
            createWalletRepository: mockCreateRepository,
            uuidProvider: uuidProvider,
            generateWallet: generateWalletMock,
            generateWrapper: generateWrapperMock,
            checksumProvider: { _ in "" }
        )

        let expectation = expectation(description: "should create wallet")

        let email = "some@some.com"
        let password = "1234"
        let accountName = "Private Key Wallet"
        creator.createWallet(email: email, password: password, accountName: accountName, language: "en")
            .sink(
                receiveCompletion: { completion in
                    guard case .failure(let error) = completion else {
                        return
                    }
                    XCTFail("should not fail: \(error)")
                },
                receiveValue: { emptyValue in
                    XCTAssertEqual(emptyValue, EmptyValue.noValue)
                    XCTAssertTrue(mockServerEntropy.getServerEntropyCalled)
                    XCTAssertTrue(uuidProviderCalled)
                    XCTAssertTrue(generateWalletCalled)
                    XCTAssertTrue(generateWrapperCalled)
                    XCTAssertTrue(mockCreateRepository.createWalletCalled)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2)
    }
}
