//
//  StellarReceiveAddressTests.swift
//  ActivityKitTests
//
//  Created by Paulo on 20/04/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import StellarKit
import XCTest

class StellarReceiveAddressTests: XCTestCase {
    struct TestData {
        let address = "1234567890"
        let label = "abcdef"
        let memo = "memo-memo"

        let urlString = "web+stellar:pay?destination=1234567890&memo=memo-memo"
        let urlStringWithMemoType = "web+stellar:pay?destination=1234567890&memo=memo-memo&memo_type=MEMO_TEXT"
        let urlStringWithAmount = "web+stellar:pay?destination=1234567890&amount=123456&memo=memo-memo"
    }

    func testStellarReceiveAddressAbsoluteURLIsCorrect() throws {
        let data = TestData()
        let address = StellarReceiveAddress(address: data.address, label: data.label, memo: data.memo)
        XCTAssertEqual(address.metadata.absoluteString, data.urlString)
    }
    func testStellarURLPayloadWithMemoTypeText() throws {
        let data = TestData()
        let url = URL(string: data.urlStringWithMemoType)!
        let address = StellarURLPayload(url: url)
        XCTAssertEqual(address?.absoluteString, data.urlString)
    }
    func testStellarURLPayloadWithoutMemoType() throws {
        let data = TestData()
        let url = URL(string: data.urlString)!
        let address = StellarURLPayload(url: url)
        XCTAssertEqual(address?.absoluteString, data.urlString)
    }
    func testStellarURLPayloadWithMemoTypeTextAmount() throws {
        let data = TestData()
        let url = URL(string: data.urlStringWithAmount)!
        let address = StellarURLPayload(url: url)
        XCTAssertEqual(address?.absoluteString, data.urlStringWithAmount)
    }
}
