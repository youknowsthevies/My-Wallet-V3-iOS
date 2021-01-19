//
//  MoneyValueConvertTests.swift
//  PlatformKitTests
//
//  Created by Paulo on 27/11/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import PlatformKit

final class MoneyValueConvertTests: XCTestCase {

    func testConvertingALGOIntoBTCUsingBTCExchangeRate() throws {
        let exchageRate = CryptoValue(amount: 400, currency: .bitcoin).moneyValue
        let value = CryptoValue(amount: 10_000, currency: .algorand).moneyValue
        let expected = CryptoValue(amount: 4, currency: .bitcoin).moneyValue
        let result = try value.convert(using: exchageRate)
        XCTAssertEqual(result, expected)
    }

    func testConvertingBTCIntoALGOUsingBTCExchangeRate() throws {
        let exchageRate = CryptoValue(amount: 400, currency: .bitcoin).moneyValue
        let value = CryptoValue(amount: 4, currency: .bitcoin).moneyValue
        let expected = CryptoValue(amount: 10_000, currency: .algorand).moneyValue
        let result = try value.convert(usingInverse: exchageRate, currencyType: .crypto(.algorand))
        XCTAssertEqual(result, expected)
    }
}
