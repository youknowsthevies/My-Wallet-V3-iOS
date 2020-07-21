//
//  MoneyValueTests.swift
//  PlatformKitTests
//
//  Created by Daniel on 15/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest

@testable import PlatformKit

final class MoneyValueChangeTests: XCTestCase {
    
    // Test value before 10% increase
    func testFiatValueBefore10PercentIncrease() throws {
        let value = FiatValue(minor: "1500", currency: .GBP)
        let expected = FiatValue(minor: "1000", currency: .GBP)
        let result = value.value(before: 0.5)
        XCTAssertEqual(result, expected)
    }
    
    // Test value before 10% increase
    func testMoneyValueBefore10PercentIncrease() throws {
        let value = try MoneyValue(major: "1", currency: CryptoCurrency.bitcoin.code)
        let expected = try MoneyValue(major: "0.9090909091", currency: CryptoCurrency.bitcoin.code)
        let result = try value.value(before: 0.1)
        XCTAssertEqual(result, expected)
    }
    
    // Test value before 10% increase
    func testCryptoValueBefore10PercentIncrease() throws {
        let value = CryptoValue(major: "1", cryptoCurrency: .bitcoin)!
        let expected = CryptoValue(major: "0.9090909091", cryptoCurrency: .bitcoin)
        let result = try value.value(before: 0.1)
        XCTAssertEqual(result, expected)
    }
    
    // Test value before 50% increase
    func testCryptoValueBefore50PercentIncrease() throws {
        let value = CryptoValue(major: "15", cryptoCurrency: .bitcoin)!
        let expected = CryptoValue(major: "10", cryptoCurrency: .bitcoin)
        let result = try value.value(before: 0.5)
        XCTAssertEqual(result, expected)
    }
}
