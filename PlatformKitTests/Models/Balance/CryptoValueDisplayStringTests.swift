//
//  CryptoValueDisplayStringTests.swift
//  PlatformKitTests
//
//  Created by Paulo on 26/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import XCTest
@testable import PlatformKit

class CryptoValueDisplayStringTests: XCTestCase {
    func testBTC() {
        let minor: CryptoValue = CryptoValue.createFromMinorValue(BigInt("1"), assetType: .bitcoin)
        let cases: [(locale: Locale, string: String)] = [
            (.US, "0.00000001 BTC"),
            (.Canada, "0.00000001 BTC"),
            (.France, "0,00000001 BTC"),
            (.Japan, "0.00000001 BTC"),
            (.GreatBritain, "0.00000001 BTC"),
            (.Lithuania, "0,00000001 BTC")
        ]
        for this in cases {
            let result = minor.toDisplayString(includeSymbol: true, locale: this.locale)
            XCTAssertEqual(
                result,
                this.string,
                "\(this.locale), \(this.string): got \(result) instead"
            )
        }
    }
}
