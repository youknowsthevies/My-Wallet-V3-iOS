// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ToolKit

import XCTest

final class ArrayRandomTests: XCTestCase {

    func test_array_of_uint8_can_provide_random_values() {
        let random = [UInt8].secureRandomBytes(count: 32)
        XCTAssertEqual(random.count, 32)
        XCTAssertFalse(random.areAllElementsEqual)
    }

    func test_array_of_uint8_returns_empty_on_zero_count() {
        let random = [UInt8].secureRandomBytes(count: 0)
        XCTAssertTrue(random.isEmpty)
    }
}
