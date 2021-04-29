// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import XCTest

class JSSourceTests: XCTestCase {

    func testMyWalletSourceIsPresent() {
        let path = Bundle.main.path(forResource: "my-wallet", ofType: "js")
        XCTAssertNotNil(path)
    }

    func testWalletIOSSourceIsPresent() {
        let path = Bundle.main.path(forResource: "wallet-ios", ofType: "js")
        XCTAssertNotNil(path)
    }
}
