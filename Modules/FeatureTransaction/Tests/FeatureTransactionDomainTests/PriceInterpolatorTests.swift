// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import FeatureTransactionDomain
import XCTest

final class PricesInterpolatorTest: XCTestCase {

    let BTC = [
        OrderPriceTier(volume: "100000", price: "49410442000", marginPrice: "49410442000"),
        OrderPriceTier(volume: "100000000", price: "49407964135", marginPrice: "49407964135"),
        OrderPriceTier(volume: "200000000", price: "49403094021", marginPrice: "49403094021"),
        OrderPriceTier(volume: "500000000", price: "49399232588", marginPrice: "49399232588")
    ]

    func rate(for amount: BigInt) -> BigInt {
        PricesInterpolator(prices: BTC).rate(amount: amount)
    }

    func test_when_amount_is_lower_than_first_volume() throws {
        try XCTAssertEqual(rate(for: "13514"), BTC[0].price)
    }

    func test_when_amount_is_higher_than_last_volume() throws {
        try XCTAssertEqual(rate(for: "572132720"), BTC[3].price)
    }

    func test_when_amount_is_higher_than_first_volume_value_is_interpolated() throws {
        try XCTAssertEqual(rate(for: "180300"), "49410440009")
    }
}

private func XCTAssertEqual(
    _ expression1: @autoclosure () throws -> BigInt,
    _ expression2: @autoclosure () throws -> String,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) throws {
    try XCTAssertEqual(expression1(), XCTUnwrap(BigInt(expression2())), message(), file: file, line: line)
}
