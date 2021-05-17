// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import EthereumKit
@testable import PlatformKit
import ToolKit
import XCTest

class EthereumTransactionEncoderTests: XCTestCase {

    var signer: EthereumTransactionSigner!
    var builder: EthereumTransactionBuilder!
    var subject: EthereumTransactionEncoder!

    override func setUp() {
        super.setUp()
        signer = EthereumTransactionSigner()
        builder = EthereumTransactionBuilder()
        subject = EthereumTransactionEncoder()
    }

    override func tearDown() {
        subject = nil
        signer = nil
        builder = nil
        super.tearDown()
    }

    func test_encode() throws {
        // swiftlint:disable line_length
        let expectedRawTx = "0xf867091782520894353535353535353535353535353535353535353588016345785d8a00008026a0b51971506a39c26b1c584df3c9ccc15fb1f890b023c5a5861b01d0d8e61b9249a00d29b3a0a38119ca1fe971d270b32a31bec2037466c2d506c194b7924996a3e1"

        let keyPair = MockEthereumWalletTestData.keyPair
        let candidate = EthereumTransactionCandidate(
            to: "0x3535353535353535353535353535353535353535",
            gasPrice: 23,
            gasLimit: 21_000,
            value: BigUInt("0.1", decimals: CryptoCurrency.ethereum.maxDecimalPlaces)!,
            data: nil
        )
        guard case let .success(costed) = builder.build(transaction: candidate, nonce: 9) else {
            XCTFail("Transaction building failed")
            return
        }
        guard case let .success(signed) = signer.sign(transaction: costed, keyPair: keyPair) else {
            XCTFail("Transaction signing failed")
            return
        }
        guard case let .success(finalised) = subject.encode(signed: signed) else {
            XCTFail("Transaction encoding failed")
            return
        }
        XCTAssertEqual(finalised.rawTransaction, expectedRawTx.lowercased())
    }
}
