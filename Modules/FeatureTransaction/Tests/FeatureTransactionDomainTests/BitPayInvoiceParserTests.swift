// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureTransactionDomain
import MoneyKit
import XCTest

final class BitPayInvoiceParserTests: XCTestCase {

    func testBitPayInvoiceParserMake() {
        let testcases: [(input: String, asset: CryptoCurrency, output: String)] = [
            ("bitcoin://?r=https://bitpay.com/i/foobar", .bitcoin, "foobar"),
            ("bitcoin:address?amount=1&r=https://bitpay.com/i/foobar", .bitcoin, "foobar"),
            ("bitcoin:address?amount=1&r=https%3A%2F%2Fbitpay.com%2Fi%2Ffoobar", .bitcoin, "foobar"),

            ("bitcoincash://?r=https://bitpay.com/i/foobar", .bitcoinCash, "foobar"),
            ("bitcoincash:address?amount=1&r=https://bitpay.com/i/foobar", .bitcoinCash, "foobar"),
            ("bitcoincash:address?amount=1&r=https%3A%2F%2Fbitpay.com%2Fi%2Ffoobar", .bitcoinCash, "foobar")
        ]

        for testcase in testcases {
            let invoiceID = try? BitPayInvoiceParser.make(from: testcase.input, asset: .bitcoin).get()
            XCTAssertEqual(invoiceID, testcase.output)
        }
    }
}
