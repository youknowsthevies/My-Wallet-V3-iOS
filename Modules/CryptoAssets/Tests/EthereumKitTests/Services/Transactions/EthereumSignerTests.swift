// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import EthereumKit
@testable import EthereumKitMock
@testable import PlatformKit
import XCTest

class EthereumSignerTests: XCTestCase {

    var subject: EthereumSigner!

    override func setUp() {
        super.setUp()
        subject = EthereumSigner()
    }

    override func tearDown() {
        subject = nil
        super.tearDown()
    }

    func test_sign_transaction() throws {
        let amount = BigUInt("0.1", decimals: CryptoCurrency.coin(.ethereum).precision)!
        let toAddress = EthereumAddress(address: "0x3535353535353535353535353535353535353535")!
        let keyPair = MockEthereumWalletTestData.keyPair
        let candidate = EthereumTransactionCandidate(
            to: toAddress,
            gasPrice: MockEthereumWalletTestData.Transaction.gasPrice,
            gasLimit: MockEthereumWalletTestData.Transaction.gasLimit,
            value: amount,
            transferType: .transfer()
        )
        guard case .success(let costed) = EthereumTransactionCandidateCosted.create(
            transaction: candidate,
            nonce: 9
        ) else {
            XCTFail("Transaction building failed")
            return
        }
        guard case .success(let signed) = subject.sign(transaction: costed, keyPair: keyPair) else {
            XCTFail("Transaction signing failed")
            return
        }
        // swiftlint:disable line_length
        let rawTransaction = "0xf86c0985028fa6ae0082520894353535353535353535353535353535353535353588016345785d8a00008026a0521f82fef48c80ca3245cc1d2be289f42f5119613fc1eea8c8e9e673d48c7b8ba017cfd25094a4f81e2c5f766e76686bc9270f22d24e8998fa1549d0c9a3d5f786"
        XCTAssertEqual(signed.encodedTransaction, Data(hexString: rawTransaction))
    }

    func test_personal_sign() throws {
        let message = "This is a test message!"
        let messageData = message.data(using: .ascii)!
        let keyPair = MockEthereumWalletTestData.keyPair
        guard case .success(let result) = subject.sign(messageData: messageData, keyPair: keyPair) else {
            XCTFail("Transaction signing failed")
            return
        }
        XCTAssertEqual(
            result.hexString.withHex,
            "0xcbe90263d29bc2e607f911a73bb9fea4faca12d664504592100992dcd2b444c352bdc10d6ba8b1e2c015842c2961c4697d4057edc3489bcac0c3155059ae969c01"
        )
    }
}
