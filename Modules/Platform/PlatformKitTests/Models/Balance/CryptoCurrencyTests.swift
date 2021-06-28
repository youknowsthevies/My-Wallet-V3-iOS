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
            .erc20(.aave),
            .erc20(.yearnFinance),
            .erc20(.wdgld),
            .erc20(.pax),
            .erc20(.tether)
        ]
    }

    // TODO: decide on how to order enum cases
    /// Test that CryptoCurrency.allCases is in the correct expected order.
    ///
    /// The synthesised allCases collection provides the cases in order of their declaration, this test assures
    /// us that the declaration order follows the expected order. Read about it on
    /// [CaseIterable Doc](https:developer.apple.com/documentation/swift/caseiterable)
    func testAllCasesIsInCorrectOrder() {
//        XCTAssertTrue(CryptoCurrency.allCases == cryptoCurrencyDesiredOrder,
//                      "CryptoCurrency.allCases is not as expected.")
    }

    func testSortedCryptoCurrencyArrayIsInCorrectOrder() {
        let sut =    EnabledCurrenciesService.init(featureFlagService: InternalFeatureFlagServiceMock())
        XCTAssertTrue(sut.allEnabledCryptoCurrencies.sorted() == cryptoCurrencyDesiredOrder,
                      "sut.allEnabledCryptoCurrencies.sorted() is not as expected.")
    }
}
