// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import EthereumKit
import XCTest

final class EIP681URIParserTests: XCTestCase {

    func testDecodeAddress() {
        let testCase = "ethereum:0xfb6916095ca1df60bb79Ce92ce3ea74c37c5d359@33?value=2.014e18&gasPrice=1&gasLimit=2"
        let eip681 = EIP681URIParser(string: testCase)
        XCTAssertNotNil(eip681)
        XCTAssertEqual("0xfb6916095ca1df60bb79Ce92ce3ea74c37c5d359", eip681?.address)
        XCTAssertEqual("33", eip681?.chainID)
        XCTAssertEqual(.send(amount: "2.014e18", gasLimit: "2", gasPrice: "1"), eip681?.method)
    }

    func testDecodeAddressPay() {
        let testCase = "ethereum:pay-0xfb6916095ca1df60bb79Ce92ce3ea74c37c5d359@33?value=2.014e18&gasPrice=1&gas=2"
        let eip681 = EIP681URIParser(string: testCase)
        XCTAssertNotNil(eip681)
        XCTAssertEqual("0xfb6916095ca1df60bb79Ce92ce3ea74c37c5d359", eip681?.address)
        XCTAssertEqual("33", eip681?.chainID)
        XCTAssertEqual(.send(amount: "2.014e18", gasLimit: "2", gasPrice: "1"), eip681?.method)
    }

    func testDecodeTransfer() {
        let testCase = "ethereum:0xfb6916095ca1df60bb79Ce92ce3ea74c37c5d359@33/transfer?address=0x8e23ee67d1332ad560396262c48ffbb01f93d052&uint256=1"
        let eip681 = EIP681URIParser(string: testCase)
        XCTAssertNotNil(eip681)
        XCTAssertEqual("0xfb6916095ca1df60bb79Ce92ce3ea74c37c5d359", eip681?.address)
        XCTAssertEqual("33", eip681?.chainID)
        XCTAssertEqual(.transfer(destination: "0x8e23ee67d1332ad560396262c48ffbb01f93d052", amount: "1"), eip681?.method)
    }
}
