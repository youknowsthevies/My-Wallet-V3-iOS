//
//  CustodialBalanceResponseTests.swift
//  PlatformKitTests
//
//  Created by Paulo on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import PlatformKit
import XCTest

class CustodialBalanceResponseTests: XCTestCase {

    func testDecodable() {
        let result: CustodialBalanceResponse! = CustodialBalanceResponse.mock(json: CustodialBalanceResponse.mockJson)
        XCTAssertNotNil(result, "CustodialBalanceResponse should exist")
        XCTAssertNotNil(result[CryptoCurrency.ethereum.code], "CustodialBalanceResponse.eth should exist")
        XCTAssertNotNil(result[CryptoCurrency.bitcoin.code], "CustodialBalanceResponse.btc should exist")
    }
}

