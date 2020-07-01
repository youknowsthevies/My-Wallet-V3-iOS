//
//  CryptoCurrencyTests.swift
//  PlatformKitTests
//
//  Created by Paulo on 31/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import PlatformKit
import XCTest

class CryptoCurrencyTests: XCTestCase {

    /// Test that CryptoCurrency.allCases is in the correct expected order.
    ///
    /// The synthesized allCases collection provides the cases in order of their declaration, this test assures
    /// us that the delcaration order follows the expected order. Read about it on
    /// [CaseIterable Doc](https:developer.apple.com/documentation/swift/caseiterable)
    func testAllCasesIsInCorrectOrder() {
        let cryptoCurrencyDesiredOrder: [CryptoCurrency] = [
            .bitcoin,
            .ethereum,
            .bitcoinCash,
            .stellar,
            .pax,
            .algorand
        ]
        XCTAssertTrue(CryptoCurrency.allCases == cryptoCurrencyDesiredOrder,
                      "CryptoCurrency.allCases is not as expected.")
    }
}
