// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import XCTest

final class BigIntExtensionTests: XCTestCase {

    func testDivision4000by2000() {
        let divisor = BigInt(20000)
        let number = BigInt(40000)
        let result = number.decimalDivision(by: divisor)
        XCTAssertEqual(result, 2)
    }

    func testDivision9999by1111() {
        let divisor = BigInt(1111)
        let number = BigInt(9999)
        let result = number.decimalDivision(by: divisor)
        XCTAssertEqual(result, 9)
    }

    func testDivision1000by0_1() {
        let divisor = Decimal(0.1)
        let number = BigInt(1000)
        let result = number.divide(by: divisor)
        XCTAssertEqual(result, 10000)
    }

    func testDivision10pow90by10powNegative90() {
        let divisior = 1 / pow(10, 90)
        let number = BigInt(10).power(90)
        let result = number.divide(by: divisior)
        XCTAssertEqual(result, BigInt(10).power(180))
    }

    func testDivisionRoundsUpLastDigit() {
        let divisor = Decimal(1.1)
        let number = BigInt(100)
        let result = number.divide(by: divisor)
        // 90.909090
        XCTAssertEqual(result, BigInt(91))
    }

    func testDivisionDoesntRoundLastDigitWhenUnnecessary() {
        let divisor = Decimal(1.1)
        let number = BigInt(95)
        let result = number.divide(by: divisor)
        // 86.363636
        XCTAssertEqual(result, BigInt(86))
    }

    func testQuotientAndRemainder99by2() {
        let number = BigInt(99)
        let divisor = BigInt(2)
        let result = number.quotientAndRemainder(dividingBy: divisor)
        XCTAssertEqual(result.quotient, BigInt(49))
        XCTAssertEqual(result.remainder, BigInt(1))
    }

    func testQuotientAndRemainder120by2() {
        let number = BigInt(120)
        let divisor = BigInt(2)
        let result = number.quotientAndRemainder(dividingBy: divisor)
        XCTAssertEqual(result.quotient, BigInt(60))
        XCTAssertEqual(result.remainder, BigInt(0))
    }
}
