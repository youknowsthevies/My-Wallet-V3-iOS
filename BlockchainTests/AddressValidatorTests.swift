//
//  AddressValidatorTests.swift
//  BlockchainTests
//
//  Created by Maurice A. on 5/29/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

@testable import Blockchain

class AddressValidatorTests: XCTestCase {

    var addressValidator: AddressValidator?

    override func setUp() {
        super.setUp()
        WalletManager.shared.wallet.loadJS()
        let context = WalletManager.shared.wallet.context
        precondition((context != nil), "JS context is required for use of AddressValidator")
        addressValidator = AddressValidator(context: context!)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAddressValidatorInitializer() {
        XCTAssertNotNil(addressValidator, "Expected the address validator to have initialized with the JS context.")
    }

    // MARK: - P2PKH Addresses

    func testAddressValidatorWithValidP2PKHAddress() {
        precondition(addressValidator != nil, "Address validator must not be nil!")
        XCTAssertTrue(addressValidator!.validate(bitcoinAddress: "1W3hBBAnECvpmpFXcBrWoBXXihJAEkTmA"), "Expected address to be valid.")
    }

    func testAddressValidatorWithInValidP2PKHAddress() {
        precondition(addressValidator != nil, "Address validator must not be nil!")
        XCTAssertFalse(addressValidator!.validate(bitcoinAddress: "1W3hBBAnECvpmpFXcBrWoBXXihJAEkTmO"), "Expected address to be invalid.")
    }

    // MARK: - P2SH Addresses (Multi-sig)

    func testAddressValidatorWithValidP2SHAddress() {
        precondition(addressValidator != nil, "Address validator must not be nil!")
        XCTAssertTrue(addressValidator!.validate(bitcoinAddress: "3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy"), "Expected address to be valid.")
    }

    // MARK: - Bitcoin Address Validation

    func testAddressValidatorWithShortBitcoinAddress() {
        precondition(addressValidator != nil, "Address validator must not be nil!")
        XCTAssertFalse(addressValidator!.validate(bitcoinAddress: "abc"), "Expected address to be invalid.")
    }

    func testAddressValidatorWithLongBitcoinAddress() {
        precondition(addressValidator != nil, "Address validator must not be nil!")
        XCTAssertFalse(addressValidator!.validate(bitcoinAddress: "ThisBitcoinAddressIsWayTooLongToBeValid"), "Expected address to be invalid.")
    }

    func testAddressValidatorWithEmptyAddress() {
        precondition(addressValidator != nil, "Address validator must not be nil!")
        XCTAssertFalse(addressValidator!.validate(bitcoinAddress: ""), "Expected address to be invalid.")
    }

    // MARK: - Bitcoin Cash Address Validation

    func testAddressValidatorWithValidLegacyBitcoinAddress() {
        precondition(addressValidator != nil, "Address validator must not be nil!")
        XCTAssertTrue(addressValidator!.validate(bitcoinCashAddress: "1K43HTP8ayuJjfqAHG7azwVDDQaDwLtqtK"), "Expected address to be invalid.")
    }

    func testAddressValidatorWithValidBitcoinCashAddress() {
        precondition(addressValidator != nil, "Address validator must not be nil!")
        XCTAssertTrue(addressValidator!.validate(bitcoinCashAddress: "qz2js9054gqxj4dww35kkc3jpf0ph4cfh53tld3zek"), "Expected address to be invalid.")
    }

    func testAddressValidatorWithInvalidBitcoinCashAddress() {
        precondition(addressValidator != nil, "Address validator must not be nil!")
        XCTAssertFalse(addressValidator!.validate(bitcoinCashAddress: "DoNotSendYourMoneyToThisAddress"), "Expected address to be invalid.")
    }
}
