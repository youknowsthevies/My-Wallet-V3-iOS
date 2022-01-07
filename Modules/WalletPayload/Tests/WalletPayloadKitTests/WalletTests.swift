// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import TestKit
import ToolKit
import XCTest

class WalletTests: XCTestCase {

    let walletV4 = Fixtures.loadJSONData(filename: "wallet.v4", in: .module)!

    let secondPassword = "secret"
    let doubleEncryptedWallet = Fixtures.loadJSONData(filename: "wallet.v4-secpass", in: .module)!

    var doubleEncBlockchainWallet: WalletResponse!
    var blockchainWalletV4: WalletResponse!

    override func setUpWithError() throws {
        doubleEncBlockchainWallet = try JSONDecoder().decode(WalletResponse.self, from: doubleEncryptedWallet)
        blockchainWalletV4 = try JSONDecoder().decode(WalletResponse.self, from: walletV4)
        try super.setUpWithError()
    }

    func test_getMnemonic_method_works() throws {
        let wallet = NativeWallet(from: blockchainWalletV4)

        let mnemonicResult = getMnemonic(from: wallet)

        let expectedMnemonic = "heart hole empty popular divert win income cute green happy fork gather"
        switch mnemonicResult {
        case .success(let mnemonic):
            XCTAssertEqual(mnemonic, expectedMnemonic)
        case .failure:
            XCTFail("should provide a mnemonic")
        }
    }

    func test_getMnemonic_method_works_with_double_encrypted_wallets() throws {
        let wallet = NativeWallet(from: doubleEncBlockchainWallet)

        let mnemonicResult = getMnemonic(from: wallet, secondPassword: secondPassword)

        let expectedMnemonic = "heart hole empty popular divert win income cute green happy fork gather"
        switch mnemonicResult {
        case .success(let mnemonic):
            XCTAssertEqual(mnemonic, expectedMnemonic)
        case .failure:
            XCTFail("should provide a mnemonic")
        }
    }

    func test_getMnemonic_method_works_with_double_encrypted_wallets_wrong_password_fails() throws {
        let wallet = NativeWallet(from: doubleEncBlockchainWallet)

        let mnemonicResult = getMnemonic(from: wallet, secondPassword: "wrong-pass")

        switch mnemonicResult {
        case .success:
            XCTFail("should not success")
        case .failure(let error):
            XCTAssertEqual(error, .initialization(.invalidSecondPassword))
        }
    }

    func test_getSeedHex_method_works() throws {
        // given
        let encryptedWallet = NativeWallet(from: doubleEncBlockchainWallet)

        // when
        let seedHexFromDoubleEncryptedWallet = getSeedHex(
            from: encryptedWallet,
            secondPassword: secondPassword
        ).successData

        // then
        XCTAssertNotNil(seedHexFromDoubleEncryptedWallet)
        XCTAssertEqual(seedHexFromDoubleEncryptedWallet, "6a4d9524d413fdf69ca1b5664d1d6db0")

        // given
        let wallet = NativeWallet(from: blockchainWalletV4)
        // when
        let seedHex = getSeedHex(from: wallet).successData

        // then
        XCTAssertNotNil(seedHex)
        XCTAssertEqual(seedHex, "6a4d9524d413fdf69ca1b5664d1d6db0")
    }

    func test_getSeedHex_method_returns_error_on_double_encrypted_wallet() {
        // given
        let encryptedWallet = NativeWallet(from: doubleEncBlockchainWallet)

        // when
        var seedHexResult = getSeedHex(
            from: encryptedWallet,
            secondPassword: nil
        )

        // then
        XCTAssertEqual(seedHexResult, .failure(.initialization(.needsSecondPassword)))

        seedHexResult = getSeedHex(
            from: encryptedWallet,
            secondPassword: "wrong-pass"
        )

        // then
        XCTAssertEqual(seedHexResult, .failure(.initialization(.invalidSecondPassword)))
    }

    func test_decrypt_value_method_successfully_decrypts_values() throws {
        let wallet = NativeWallet(from: doubleEncBlockchainWallet)

        guard let seedHex = wallet.defaultHDWallet?.seedHex else {
            XCTFail("seedHex not found of wallet")
            return
        }

        let decryptedSeedHexResult = decryptValue(
            secondPassword: "secret",
            wallet: wallet,
            value: seedHex
        )

        switch decryptedSeedHexResult {
        case .success(let hex):
            XCTAssertEqual(hex, "6a4d9524d413fdf69ca1b5664d1d6db0")
        case .failure:
            XCTFail("should not fail")
        }
    }

    func test_decrypt_value_method_returns_correct_error() throws {
        let wallet = NativeWallet(from: doubleEncBlockchainWallet)

        guard let seedHex = wallet.defaultHDWallet?.seedHex else {
            XCTFail("seedHex not found of wallet")
            return
        }

        let decryptedSeedHexResult = decryptValue(
            secondPassword: "wrong-pass",
            wallet: wallet,
            value: seedHex
        )

        switch decryptedSeedHexResult {
        case .success:
            XCTFail("should fail with correct error")
        case .failure(let error):
            XCTAssertEqual(error, .initialization(.invalidSecondPassword))
        }
    }

    func test_validate_second_password_method() throws {
        let wallet = NativeWallet(from: doubleEncBlockchainWallet)

        let result: Result<String, WalletError> = validateSecondPassword(
            password: "secret",
            wallet: wallet
        ) { _ in
            .success("some-value")
        }

        switch result {
        case .success(let value):
            XCTAssertEqual(value, "some-value")
        case .failure:
            XCTFail("should not happen")
        }
    }

    func test_validate_second_password_method_return_correct_error() throws {
        let wallet = NativeWallet(from: doubleEncBlockchainWallet)

        let result: Result<String, WalletError> = validateSecondPassword(
            password: "wrong-pass",
            wallet: wallet
        ) { _ in
            XCTFail("should not execute this method")
            return .success("some-value")
        }

        switch result {
        case .success:
            XCTFail("should raise an error")
        case .failure(let error):
            XCTAssertEqual(error, .initialization(.invalidSecondPassword))
        }
    }

    func test_second_password_isValid_method() throws {
        let wallet = NativeWallet(from: doubleEncBlockchainWallet)

        XCTAssertTrue(
            isValid(secondPassword: secondPassword, wallet: wallet)
        )

        XCTAssertFalse(
            isValid(secondPassword: "wrong-pass", wallet: wallet)
        )
    }

    func test_second_password_isValid_method_stops_on_non_double_encrypted_wallets() throws {
        let wallet = NativeWallet(from: blockchainWalletV4)

        XCTAssertFalse(
            isValid(secondPassword: secondPassword, wallet: wallet)
        )
    }
}
