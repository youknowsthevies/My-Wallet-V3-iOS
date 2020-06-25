//
//  JSSourceTests.swift
//  BlockchainTests
//
//  Created by Paulo on 15/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

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
