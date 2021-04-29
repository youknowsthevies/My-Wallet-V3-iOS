// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import PlatformKit
import XCTest

class PinTests: XCTestCase {

    func testInValidPin() {
        let pin = Pin(code: 0000)
        XCTAssertFalse(pin.isValid)
    }

    func testValidPin() {
        let pin = Pin(code: 6309)
        XCTAssertTrue(pin.isValid)
    }
}
