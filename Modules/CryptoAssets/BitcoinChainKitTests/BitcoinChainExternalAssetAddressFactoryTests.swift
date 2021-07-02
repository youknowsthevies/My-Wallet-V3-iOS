// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
import XCTest

class BitcoinChainExternalAssetAddressFactoryTests: XCTestCase {
    var sut: BitcoinChainExternalAssetAddressFactory!

    override func setUp() {
        super.setUp()
        sut = .init()
    }

    static var validTestCases: [String] = [
        "bc1q2ddhp55sq2l4xnqhpdv0xazg02v9dr7uu8c2p2",
        "1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2",
        "3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy",
        "1W3hBBAnECvpmpFXcBrWoBXXihJAEkTmA",
        "3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy",
        "bc1qzf9j339nc5qs58usysm3zhgpsev6gacsmapnzq",
        "1K43HTP8ayuJjfqAHG7azwVDDQaDwLtqtK"
    ]

    func testValid() {
        for testcase in Self.validTestCases {
            XCTAssertTrue(sut.validate(address: testcase), testcase)
        }
    }

    static var invalidTestCases: [String] = [
        "bc1q2ddhp55sq2l4xnqhpdv9xazg02v9dr7uu8c2p2",
        "MPmoY6RX3Y3HFjGEnFxyuLPCQdjvHwMEny",
        "1W3hBBAnECvpmpFXcBrWoBXXihJAEkTmO",
        "abc",
        "ThisBitcoinAddressIsWayTooLongToBeValid",
        "",
        "DoNotSendYourMoneyToThisAddress",
        "bitcoin:bc1qzf9j339nc5qs58usysm3zhgpsev6gacsmapnzq"
    ]

    func testInvalid() {
        for testcase in Self.invalidTestCases {
            XCTAssertFalse(sut.validate(address: testcase), testcase)
        }
    }
}
