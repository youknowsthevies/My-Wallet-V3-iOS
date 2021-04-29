// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit
import XCTest

class StringHexTests: XCTestCase {

    func testHasHex() throws {
        let pairs: [(testcase: String, result: Bool)] = [
            //
            ("0x0x", true),
            ("0x", true),
            ("0x1", true),
            ("0xa", true),

            //
            (" 0x", false),
            ("00x", false),
            ("a0x1", false),
            ("a0xa", false)
        ]
        for pair in pairs {
            XCTAssertEqual(pair.testcase.hasHexPrefix, pair.result)
        }
    }

    func testWithHex() throws {
        let pairs: [(testcase: String, result: String)] = [
            //
            ("0x", "0x"),
            ("0xa", "0xa"),
            ("0x1", "0x1"),

            //
            ("", "0x"),
            (" ", "0x "),
            (" 0x", "0x 0x"),
            ("a", "0xa"),
            ("1", "0x1"),
            ("x", "0xx"),
            ("0", "0x0")
        ]
        for pair in pairs {
            XCTAssertEqual(pair.testcase.withHex, pair.result)
        }
    }

    func testWithoutHex() throws {
        let pairs: [(testcase: String, result: String)] = [
            //
            ("0x", ""),
            ("0xa", "a"),
            ("0x1", "1"),

            //
            ("", ""),
            (" ", " "),
            (" 0x", " 0x"),
            ("a", "a"),
            ("1", "1"),
            ("x", "x"),
            ("0", "0")
        ]
        for pair in pairs {
            XCTAssertEqual(pair.testcase.withoutHex, pair.result)
        }
    }
}
