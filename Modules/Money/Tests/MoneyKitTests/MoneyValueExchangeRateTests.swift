import BigInt
import MoneyKit
@testable import MoneyKitMock
import XCTest

final class MoneyValueExchangeRateTests: XCTestCase {

    func test_ExchangeRate_fromPrecision6_toPrecision18() {
        let base = MoneyValue(
            cryptoValue: CryptoValue(
                amount: 2_000_000, // 2.0
                currency: .mockCoin(
                    symbol: "P6",
                    name: "PRECISION_6",
                    precision: 6
                )
            )
        )
        let quote = MoneyValue(
            cryptoValue: CryptoValue(
                amount: 5_000_000_000_000_000_000, // 50.0
                currency: .mockCoin(
                    symbol: "P18",
                    name: "PRECISION_18",
                    precision: 18
                )
            )
        )
        let exchangeRate = MoneyValuePair(base: base, quote: quote).exchangeRate

        let expected = MoneyValuePair(
            base: MoneyValue(amount: 1_000_000, currency: base.currencyType),
            exchangeRate: MoneyValue(amount: 2_500_000_000_000_000_000, currency: quote.currencyType)
        )
        XCTAssertEqual(expected, exchangeRate)
    }

    func test_ExchangeRate_fromPrecision8_toPrecision8() {
        let base = MoneyValue(
            cryptoValue: CryptoValue(
                amount: 50_000_000, // 0.5 BTC
                currency: .bitcoin
            )
        )
        let quote = MoneyValue(
            cryptoValue: CryptoValue(
                amount: 7_222_000_000, // 72.22 BCH
                currency: .bitcoinCash
            )
        )
        let exchangeRate = MoneyValuePair(base: base, quote: quote).exchangeRate

        let expected = MoneyValuePair(
            base: MoneyValue(amount: 100_000_000, currency: base.currencyType), // 1 BTC
            exchangeRate: MoneyValue(amount: 14_444_000_000, currency: quote.currencyType) // 144.44 BCH
        )
        XCTAssertEqual(expected, exchangeRate)
    }

    func test_ExchangeRate_fromPrecision18_toPrecision8() {
        let base = MoneyValue(
            cryptoValue: CryptoValue(
                amount: BigInt(1e16), // 0.01
                currency: .mockCoin(
                    symbol: "P18",
                    name: "PRECISION_18",
                    precision: 18
                )
            )
        )
        let quote = MoneyValue(
            cryptoValue: CryptoValue(
                amount: 123_456, // 0.00123456
                currency: .bitcoinCash // Precision 8
            )
        )
        let exchangeRate = MoneyValuePair(base: base, quote: quote).exchangeRate

        let expected = MoneyValuePair(
            base: MoneyValue(amount: BigInt(1e18), currency: base.currencyType),
            exchangeRate: MoneyValue(amount: 123_45600, currency: quote.currencyType)
        )
        XCTAssertEqual(expected, exchangeRate)
    }

    func test_InvertedExchangeRate_fromPrecision6_toPrecision18() {
        let base = MoneyValue(
            cryptoValue: CryptoValue(
                amount: 2_000_000, // 2.0
                currency: .mockCoin(
                    symbol: "P6",
                    name: "PRECISION_6",
                    precision: 6
                )
            )
        )
        let quote = MoneyValue(
            cryptoValue: CryptoValue(
                amount: 5_000_000_000_000_000_000, // 50.0
                currency: .mockCoin(
                    symbol: "P18",
                    name: "PRECISION_18",
                    precision: 18
                )
            )
        )
        let exchangeRate = MoneyValuePair(base: base, quote: quote).inverseExchangeRate

        let expected = MoneyValuePair(
            base: MoneyValue(amount: 1_000_000_000_000_000_000, currency: quote.currencyType), // 1
            exchangeRate: MoneyValue(amount: 400_000, currency: base.currencyType) // 0.4
        )
        XCTAssertEqual(expected, exchangeRate)
    }
}
