// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit
import XCTest

class CustodialBalanceResponseTests: XCTestCase {

    func testDecodable() {
        let result: CustodialBalanceResponse! = CustodialBalanceResponse.mock(json: CustodialBalanceResponse.mockJson)
        XCTAssertNotNil(result, "CustodialBalanceResponse should exist")
        XCTAssertNotNil(result[.crypto(CryptoCurrency.ethereum)], "CustodialBalanceResponse.eth should exist")
        XCTAssertNotNil(result[.crypto(CryptoCurrency.bitcoin)], "CustodialBalanceResponse.btc should exist")
    }
}

