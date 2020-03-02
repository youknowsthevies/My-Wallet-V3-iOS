//
//  CustodialBalanceTests.swift
//  PlatformKitTests
//
//  Created by Paulo on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
@testable import PlatformKit

class CustodialBalanceTests: XCTestCase {

    func testInitialiser() {
        let response: CustodialBalanceResponse! = .mock(json: CustodialBalanceResponse.mockJson)

        XCTAssertNotNil(response)
        XCTAssertNotNil(response.eth)
        XCTAssertNotNil(response.btc)

        let bitcoin = CustodialBalance(currency: .bitcoin, response: response.btc!)
        XCTAssertEqual(bitcoin.available.amount, 0, "CryptoCurrency.bitcoin available should be 0")
        XCTAssertEqual(bitcoin.pending.amount, 0, "CryptoCurrency.bitcoin pending should be 0")

        let ethereum = CustodialBalance(currency: .ethereum, response: response.eth!)
        XCTAssertEqual(ethereum.available.amount, 100, "CryptoCurrency.ethereum available should be 100")
        XCTAssertEqual(ethereum.pending.amount, 100, "CryptoCurrency.ethereum pending should be 100")
    }
}

