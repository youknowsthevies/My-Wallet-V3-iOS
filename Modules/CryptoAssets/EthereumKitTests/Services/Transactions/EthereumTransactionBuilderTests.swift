// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import EthereumKit
import PlatformKit
import XCTest

class EthereumTransactionBuilderTests: XCTestCase {

    var subject: EthereumTransactionBuilder!

    override func setUp() {
        super.setUp()
        subject = EthereumTransactionBuilder()
    }

    override func tearDown() {
        subject = nil
        super.tearDown()
    }

    func test_build_transaction() {
        let toAddress = EthereumAddress(stringLiteral: "0x3535353535353535353535353535353535353535")
        let value: BigUInt = BigUInt("0.01658472", decimals: CryptoCurrency.ethereum.maxDecimalPlaces)!
        let nonce = MockEthereumWalletTestData.Transaction.nonce
        let gasPrice = MockEthereumWalletTestData.Transaction.gasPrice
        let gasLimit = MockEthereumWalletTestData.Transaction.gasLimit

        let transaction = EthereumTransactionCandidate(
            to: toAddress,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            value: value,
            data: nil
        )

        let result = subject.build(
            transaction: transaction,
            nonce: nonce
        )

        guard case let .success(costed) = result else {
            XCTFail("The transaction should be built successfully")
            return
        }

        let input = costed.transaction
        XCTAssertEqual(input.gasLimit.hexString, "5208")
        XCTAssertEqual(input.gasPrice.hexString, "028fa6ae00")
        XCTAssertEqual(input.nonce.hexString, "09")
        XCTAssertEqual(input.toAddress, "0x3535353535353535353535353535353535353535")
        XCTAssertEqual(input.transaction.transfer.amount.hexString, "3aebb7084ca000")
        XCTAssertEqual(input.transaction.transfer.data.hexString, "")
        XCTAssertEqual(input.chainID.hexString, "01")
    }

    func test_build_transaction_failure_gas_limit() {
        let toAddress = EthereumAddress(stringLiteral: "0x3535353535353535353535353535353535353535")
        let value: BigUInt = BigUInt("0.01658472", decimals: CryptoCurrency.ethereum.maxDecimalPlaces)!
        let nonce = MockEthereumWalletTestData.Transaction.nonce
        let gasPrice: BigUInt = MockEthereumWalletTestData.Transaction.gasPrice
        let gasLimit: BigUInt = 0

        let transaction = EthereumTransactionCandidate(
            to: toAddress,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            value: value,
            data: nil
        )

        let result = subject.build(
            transaction: transaction,
            nonce: nonce
        )

        guard case let .failure(error) = result else {
            XCTFail("The transaction should not be built")
            return
        }
        XCTAssertEqual(error, EthereumKitValidationError.noGasLimit)
    }

    func test_build_transaction_failure_gas_price() {
        let toAddress = EthereumAddress(stringLiteral: "0x3535353535353535353535353535353535353535")
        let value: BigUInt = BigUInt("0.01658472", decimals: CryptoCurrency.ethereum.maxDecimalPlaces)!
        let nonce = MockEthereumWalletTestData.Transaction.nonce
        let gasPrice: BigUInt = 0
        let gasLimit = MockEthereumWalletTestData.Transaction.gasLimit

        let transaction = EthereumTransactionCandidate(
            to: toAddress,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            value: value,
            data: nil
        )

        let result = subject.build(
            transaction: transaction,
            nonce: nonce
        )

        guard case let .failure(error) = result else {
            XCTFail("The transaction should not be built")
            return
        }
        XCTAssertEqual(error, EthereumKitValidationError.noGasPrice)
    }
}
