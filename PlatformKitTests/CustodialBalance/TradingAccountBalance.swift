//
//  TradingAccountBalance.swift
//  PlatformKitTests
//
//  Created by Paulo on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import PlatformKit

class TradingAccountBalanceTests: XCTestCase {

    func testInitialiser() {
        let bitcoin = TradingAccountBalance(currency: .bitcoin, response: .init(available: "0", pending: "0"))
        XCTAssertEqual(bitcoin.available.amount, 0, "CryptoCurrency.bitcoin available should be 0")
        XCTAssertEqual(bitcoin.pending.amount, 0, "CryptoCurrency.bitcoin pending should be 0")

        let ethereum = TradingAccountBalance(currency: .ethereum, response: .init(available: "100", pending: "100"))
        XCTAssertEqual(ethereum.available.amount, 100, "CryptoCurrency.ethereum available should be 100")
        XCTAssertEqual(ethereum.pending.amount, 100, "CryptoCurrency.ethereum pending should be 100")
    }
}

