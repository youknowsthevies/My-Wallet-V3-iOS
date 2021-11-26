// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import PlatformKit
import XCTest

final class SimpleBuyQuoteTests: XCTestCase {

    func testAllRegions() throws {
        let sut = try createTestCases(locales: [.US, .Canada, .GreatBritain, .France, .Japan, .Lithuania])
        for this in sut {
            XCTAssertNotNil(this.quote)
            XCTAssertFalse(this.quote.estimatedCryptoAmount.isZero, "\(this.locale) has zero estimatedAmount")
            XCTAssertEqual(this.quote.fee.displayMajorValue, 10, "\(this.locale) fee major value should be 12.5")
        }
    }
}

extension SimpleBuyQuoteTests {

    private struct QuoteTestCase {
        let locale: Locale
        let response: QuoteResponse
        let quote: Quote!
    }

    private func createTestCases(locales: [Locale]) throws -> [QuoteTestCase] {
        try locales.map { try createTestCase(locale: $0) }
    }

    private func createTestCase(locale: Locale) throws -> QuoteTestCase {
        let response = QuoteResponse(
            quoteId: "00000000-0000-0000-0000-000000000000",
            quoteMarginPercent: 0.5,
            quoteCreatedAt: "2021-12-31T01:00:02.030000000Z",
            quoteExpiresAt: "2021-12-31T01:00:04.030000000Z",
            price: "5830206",
            networkFee: nil,
            staticFee: nil,
            feeDetails: .init(
                feeWithoutPromo: "10",
                fee: "10",
                feeFlags: []
            ),
            settlementDetails: .init(
                availability: .instant
            ),
            sampleDepositAddress: nil
        )
        let twoThousandFiveHundred = FiatValue.create(minor: "250000", currency: .GBP)!
        let quote = try Quote(
            to: .coin(.bitcoin),
            amount: twoThousandFiveHundred,
            response: response
        )
        return QuoteTestCase(locale: locale, response: response, quote: quote)
    }
}
