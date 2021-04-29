// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import XCTest

@testable import Blockchain

class AddressValidatorTests: XCTestCase {

    var addressValidator: AddressValidator!

    override func setUp() {
        super.setUp()
        WalletManager.shared.wallet.loadJS()
        let context = WalletManager.shared.wallet.context
        precondition((context != nil), "JS context is required for use of AddressValidator")
        addressValidator = AddressValidator(context: context!)
    }

    override func tearDown() {
        super.tearDown()
        addressValidator = nil
    }

    // MARK: - P2PKH Addresses

    func testAddressValidatorWithValidP2PKHAddress() {
        XCTAssertTrue(addressValidator!.validate(bitcoinAddress: "1W3hBBAnECvpmpFXcBrWoBXXihJAEkTmA"), "Expected address to be valid.")
    }

    func testAddressValidatorWithInValidP2PKHAddress() {
        XCTAssertFalse(addressValidator!.validate(bitcoinAddress: "1W3hBBAnECvpmpFXcBrWoBXXihJAEkTmO"), "Expected address to be invalid.")
    }

    // MARK: - P2SH Addresses (Multi-sig)

    func testAddressValidatorWithValidP2SHAddress() {
        XCTAssertTrue(addressValidator!.validate(bitcoinAddress: "3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy"), "Expected address to be valid.")
    }

    // MARK: - Bech32 SegWit

    func testAddressValidatorWithValidBech32SegWitAddress() {
        XCTAssertTrue(addressValidator!.validate(bitcoinAddress: "bc1qzf9j339nc5qs58usysm3zhgpsev6gacsmapnzq"), "Expected address to be valid.")
    }

    // MARK: - Bitcoin Address Validation

    func testAddressValidatorWithShortBitcoinAddress() {
        XCTAssertFalse(addressValidator!.validate(bitcoinAddress: "abc"), "Expected address to be invalid.")
    }

    func testAddressValidatorWithLongBitcoinAddress() {
        XCTAssertFalse(addressValidator!.validate(bitcoinAddress: "ThisBitcoinAddressIsWayTooLongToBeValid"), "Expected address to be invalid.")
    }

    func testAddressValidatorWithEmptyAddress() {
        XCTAssertFalse(addressValidator!.validate(bitcoinAddress: ""), "Expected address to be invalid.")
    }

    // MARK: - Bitcoin Cash Address Validation

    func testAddressValidatorWithValidLegacyBitcoinAddress() {
        XCTAssertTrue(addressValidator!.validate(bitcoinCashAddress: "1K43HTP8ayuJjfqAHG7azwVDDQaDwLtqtK"), "Expected address to be invalid.")
    }

    func testAddressValidatorWithValidBitcoinCashAddress() {
        XCTAssertTrue(addressValidator!.validate(bitcoinCashAddress: "qz2js9054gqxj4dww35kkc3jpf0ph4cfh53tld3zek"), "Expected address to be invalid.")
    }

    func testAddressValidatorWithInvalidBitcoinCashAddress() {
        XCTAssertFalse(addressValidator!.validate(bitcoinCashAddress: "DoNotSendYourMoneyToThisAddress"), "Expected address to be invalid.")
    }
}
