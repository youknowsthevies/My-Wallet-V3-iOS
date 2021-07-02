// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit
import XCTest

class CryptoCurrencyTests: XCTestCase {

    private var cryptoCurrencyDesiredOrder: [CryptoCurrency] {
        [
            .bitcoin,
            .ethereum,
            .bitcoinCash,
            .stellar,
            .algorand,
            .polkadot,
            CryptoCurrency.mockERC20(name: "111", sortIndex: 0),
            CryptoCurrency.mockERC20(name: "222", sortIndex: 1),
            CryptoCurrency.mockERC20(name: "333", sortIndex: 2),
            CryptoCurrency.mockERC20(name: "444", sortIndex: 3),
            CryptoCurrency.mockERC20(name: "555", sortIndex: 4)
        ]
    }

    func testSortedCryptoCurrencyArrayIsInCorrectOrder() {
        XCTAssertTrue(
            cryptoCurrencyDesiredOrder.shuffled().sorted() == cryptoCurrencyDesiredOrder,
            "sut.allEnabledCryptoCurrencies.sorted() is not as expected."
        )
    }
}
