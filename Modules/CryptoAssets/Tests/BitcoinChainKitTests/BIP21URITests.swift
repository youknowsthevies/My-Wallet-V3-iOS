// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
import XCTest

final class BIP21URITests: XCTestCase {

    enum TestData {
        enum Scheme {
            static let valid = "bitcoin"
            static let invalid = "deadbeef"
        }

        enum Address {
            static let valid = "1Amu4uPJnYbUXX2HhDFMNq7tSneDwWYDyv"
        }

        enum Amount {
            static let valid = "1.03"
        }
    }

    func testSchemes() {
        XCTAssertEqual(BitcoinToken.coin.uriScheme, "bitcoin")
        XCTAssertEqual(BitcoinCashToken.coin.uriScheme, "bitcoincash")
    }

    func testInvalidScheme() {
        let url1 = URL(string: TestData.Scheme.invalid)!
        let url2 = URL(string: "\(TestData.Scheme.invalid):\(TestData.Address.valid)")!
        let payload1 = BIP21URI<BitcoinToken>(url: url1)
        let payload2 = BIP21URI<BitcoinToken>(url: url2)
        XCTAssertNil(payload1)
        XCTAssertNil(payload2)
    }

    func testEmptyURI() {
        let url = URL(
            string: "\(TestData.Scheme.valid)://"
        )!
        let payload = BIP21URI<BitcoinToken>(url: url)
        XCTAssertNil(payload)
    }

    func testBitcoinWebFormat() {
        let url = URL(
            string: "\(TestData.Scheme.valid):\(TestData.Address.valid)"
        )!
        let payload = BIP21URI<BitcoinToken>(url: url)
        XCTAssertNotNil(payload)
        XCTAssertEqual(TestData.Address.valid, payload?.address)
    }

    func testBitcoinWebFormatWithAmount() {
        let url = URL(
            string: "\(TestData.Scheme.valid):\(TestData.Address.valid)?amount=\(TestData.Amount.valid)"
        )!
        let payload = BIP21URI<BitcoinToken>(url: url)
        XCTAssertNotNil(payload)
        XCTAssertEqual(TestData.Address.valid, payload?.address)
        XCTAssertEqual(TestData.Amount.valid, payload?.amount)
    }

    func testBitcoinAddressInHost() {
        let url = URL(
            string: "\(TestData.Scheme.valid)://\(TestData.Address.valid)"
        )!
        let payload = BIP21URI<BitcoinToken>(url: url)
        XCTAssertNotNil(payload)
        XCTAssertEqual(TestData.Address.valid, payload?.address)
    }

    func testBitcoinAddressInQueryArg() {
        let url = URL(
            string: "\(TestData.Scheme.valid)://?address=\(TestData.Address.valid)"
        )!
        let payload = BIP21URI<BitcoinToken>(url: url)
        XCTAssertNotNil(payload)
        XCTAssertEqual(TestData.Address.valid, payload?.address)
    }

    func testBitcoinAddressAndAmount() {
        let url = URL(
            string: "\(TestData.Scheme.valid)://\(TestData.Address.valid)?amount=\(TestData.Amount.valid)"
        )!
        let payload = BIP21URI<BitcoinToken>(url: url)
        XCTAssertNotNil(payload)
        XCTAssertEqual(TestData.Address.valid, payload?.address)
        XCTAssertEqual(TestData.Amount.valid, payload?.amount)
    }

    func testBitcoinPaymentRequestUrl() {
        let url = URL(
            string: "bitcoin://?r=https://bitpay.com/i/7pZrguiGf21Y73rPN8J3s5"
        )!
        let payload = BIP21URI<BitcoinToken>(url: url)
        XCTAssertNil(payload)
    }
}
