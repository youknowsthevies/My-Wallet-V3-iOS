// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit
import XCTest

final class MoneyValueConvertTests: XCTestCase {

    func testConvertingALGOIntoBTCUsingBTCExchangeRate() throws {
        let exchageRate = CryptoValue(amount: 400, currency: .bitcoin).moneyValue
        let value = CryptoValue(amount: 10_000, currency: .other(.algorand)).moneyValue
        let expected = CryptoValue(amount: 4, currency: .bitcoin).moneyValue
        let result = try value.convert(using: exchageRate)
        XCTAssertEqual(result, expected)
    }

    func testConvertingBTCIntoALGOUsingBTCExchangeRate() throws {
        let exchageRate = CryptoValue(amount: 400, currency: .bitcoin).moneyValue
        let value = CryptoValue(amount: 4, currency: .bitcoin).moneyValue
        let expected = CryptoValue(amount: 10_000, currency: .other(.algorand)).moneyValue
        let result = try value.convert(usingInverse: exchageRate, currencyType: .crypto(.other(.algorand)))
        XCTAssertEqual(result, expected)
    }
}
