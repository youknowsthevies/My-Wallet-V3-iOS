// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit
@testable import MoneyKitMock
import XCTest

final class MoneyValueConvertTests: XCTestCase {

    var mockCoin6Precision: CryptoCurrency {
        .mockCoin(symbol: "A", displaySymbol: "A", name: "MOCK", precision: 6, sortIndex: 0)
    }

    func testConvertingALGOIntoBTCUsingBTCExchangeRate() {
        let exchangeRate = CryptoValue(
            amount: 400,
            currency: .bitcoin
        )
        let value = CryptoValue(
            amount: 10000,
            currency: mockCoin6Precision
        )

        let expected = CryptoValue(
            amount: 4,
            currency: .bitcoin
        )
        let result = value.convert(using: exchangeRate)
        XCTAssertEqual(result, expected)
    }
}
