//
//  MoneyOperatingTests.swift
//  PlatformKitTests
//
//  Created by Paulo on 17/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
@testable import PlatformKit
import XCTest

// Tests default implementations of MoneyOperating
final class MoneyOperatingTests: XCTestCase {

    func moneyValue(_ uInt: UInt) -> MoneyValue {
        MoneyValue(amount: BigInt(uInt), currency: .fiat(.USD))
    }

    func testMoneyValueMultiplication() throws {
        let r = try moneyValue(15_01) * moneyValue(100_02)
        XCTAssertEqual(r.amount, BigInt(1_501_30))
    }

    func testMoneyValueDivision() throws {
        let r1 = try moneyValue(15_01) / moneyValue(100_02)
        XCTAssertEqual(r1.amount, BigInt(15))
        let r2 = try moneyValue(150_01) / moneyValue(100_02)
        XCTAssertEqual(r2.amount, BigInt(1_49))
        let r3 = try moneyValue(1_00) / moneyValue(100_00)
        XCTAssertEqual(r3.amount, BigInt(0_01))
        let r4 = try moneyValue(1_000_000_00) / moneyValue(1_000_00)
        XCTAssertEqual(r4.amount, BigInt(1000_00))
    }
}
