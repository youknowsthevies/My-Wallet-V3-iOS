// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import EthereumKit
import XCTest

final class EIP681URIParserTests: XCTestCase {

    enum TestCase {
        static let address = "0x8e23ee67d1332ad560396262c48ffbb01f93d052"
        static let contract = "0xfb6916095ca1df60bb79Ce92ce3ea74c37c5d359"
        static let sendString = "ethereum:\(address)@33?value=2.014e18&gasPrice=10&gasLimit=20"
        static let paySendString = "ethereum:pay-\(address)@33?value=2.014e18&gasPrice=10&gasLimit=20"
        static let transferString = "ethereum:\(contract)@33/transfer?address=\(address)&uint256=1"
    }

    func testDecodeAddress() {
        let eip681 = EIP681URIParser(string: TestCase.sendString)
        XCTAssertNotNil(eip681)
        XCTAssertEqual(TestCase.address, eip681?.address)
        XCTAssertEqual("33", eip681?.chainID)
        XCTAssertEqual(.send(amount: "2.014e18", gasLimit: "20", gasPrice: "10"), eip681?.method)
    }

    func testDecodeAddressPay() {
        let eip681 = EIP681URIParser(string: TestCase.paySendString)
        XCTAssertNotNil(eip681)
        XCTAssertEqual(TestCase.address, eip681?.address)
        XCTAssertEqual("33", eip681?.chainID)
        XCTAssertEqual(.send(amount: "2.014e18", gasLimit: "20", gasPrice: "10"), eip681?.method)
    }

    func testDecodeTransfer() {
        let eip681 = EIP681URIParser(string: TestCase.transferString)
        XCTAssertNotNil(eip681)
        XCTAssertEqual(TestCase.contract, eip681?.address)
        XCTAssertEqual("33", eip681?.chainID)
        XCTAssertEqual(.transfer(destination: TestCase.address, amount: "1"), eip681?.method)
    }
}
