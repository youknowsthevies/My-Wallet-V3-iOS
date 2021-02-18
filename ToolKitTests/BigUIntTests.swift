//
//  BigUIntTests.swift
//  ToolKitTests
//
//  Created by Paulo on 05/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import ToolKit
import XCTest

class BigUIntTests: XCTestCase {

    func test_hex_string_biguint() {
        XCTAssertEqual(BigUInt(0).hexString, "00")
        XCTAssertEqual(BigUInt(9).hexString, "09")
        XCTAssertEqual(BigUInt(100_000_000).hexString, "05f5e100")
        XCTAssertEqual(BigUInt(3_600_000_000).hexString, "d693a400")
        XCTAssertEqual(BigUInt(11_000_000_000).hexString, "028fa6ae00")
        XCTAssertEqual(BigUInt(16_584_720_000_000_000).hexString, "3aebb7084ca000")
        XCTAssertEqual(BigUInt(160_584_720_000_000_000).hexString, "023a82f3b7f4a000")
        XCTAssertEqual(BigUInt(1_060_584_720_000_000_000).hexString, "0eb7f42f01cea000")
        XCTAssertEqual(BigUInt(12_060_584_720_000_000_000).hexString, "a75fcde7331aa000")
        XCTAssertEqual(BigUInt(15_000_000_000_000_000_000).hexString, "d02ab486cedc0000")
        XCTAssertEqual(BigUInt(18_445_000_000_000_000_000).hexString, "fff9cdc632148000")
        XCTAssertEqual(BigUInt("23000000000000000000").hexString, "013f306a2409fc0000")
        XCTAssertEqual(BigUInt("99999999000000000000000000").hexString, "52b7d2cee7561f3c9c0000")
    }
}
