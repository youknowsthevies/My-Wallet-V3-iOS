//
//  SimpleBuySuggestedAmountsTests.swift
//  PlatformKitTests
//
//  Created by Paulo on 31/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import PlatformKit
import XCTest

class SimpleBuySuggestedAmountsTests: XCTestCase {

    func testDecoding() throws {
        let decoder = JSONDecoder()
        let data: Data = SimpleBuySuggestedAmountsTests.json.data(using: .utf8)!
        let decoded: SimpleBuySuggestedAmountsResponse! = try? decoder.decode(SimpleBuySuggestedAmountsResponse.self, from: data)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.amounts.count, 2)
        guard let response = decoded else { return }
        let amounts = SimpleBuySuggestedAmounts(response: response)
        XCTAssertEqual(amounts[.EUR].count, 3)
        XCTAssertEqual(amounts[.GBP].count, 3)
    }

    func testDecodingInvalidJSON() throws {
        let decoder = JSONDecoder()
        let data: Data = SimpleBuySuggestedAmountsTests.invalidJson.data(using: .utf8)!
        let decoded: SimpleBuySuggestedAmountsResponse! = try? decoder.decode(SimpleBuySuggestedAmountsResponse.self, from: data)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.amounts.count, 3)
        guard let response = decoded else { return }
        let amounts = SimpleBuySuggestedAmounts(response: response)
        XCTAssertEqual(amounts[.EUR].count, 3)
        XCTAssertEqual(amounts[.GBP].count, 3)
    }

    static private let json = """
    [
      {
        "EUR": [
          "25000",
          "50000",
          "100000"
        ]
      },
      {
        "GBP": [
          "25000",
          "50000",
          "100000"
        ]
      }
    ]
    """

    static private let invalidJson = """
    [
      {
        "not_a_currency": [
          "25000",
          "50000",
          "100000"
        ]
      },
      {
        "EUR": [
        "25000",
        "50000",
        "100000"
        ]
      },
      {
        "GBP": [
          "25000",
          "50000",
          "100000"
        ]
      }
    ]
    """
}
