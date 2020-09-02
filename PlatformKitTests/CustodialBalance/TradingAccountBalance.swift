//
//  TradingAccountBalance.swift
//  PlatformKitTests
//
//  Created by Paulo on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import PlatformKit
import XCTest

class TradingAccountBalanceTests: XCTestCase {

    func testInitialiser() {
        let bitcoin = CustodialAccountBalance(currency: .crypto(.bitcoin), response: .init(available: "0", withdrawable: "0"))
        XCTAssertEqual(bitcoin.available.amount, 0, "CryptoCurrency.bitcoin available should be 0")

        let ethereum = CustodialAccountBalance(currency: .crypto(.ethereum), response: .init(available: "100", withdrawable: "0"))
        XCTAssertEqual(ethereum.available.amount, 100, "CryptoCurrency.ethereum available should be 100")
    }
}

