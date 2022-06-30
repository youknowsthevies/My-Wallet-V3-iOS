// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import BitcoinChainKit
import MoneyKit
import PlatformKit
import XCTest

class TransactionSizeCalculatorTests: XCTestCase {

    var subject: TransactionSizeCalculating!

    override func setUp() {
        super.setUp()
        subject = TransactionSizeCalculator()
    }

    override func tearDown() {
        subject = nil
        super.tearDown()
    }

    struct TestCase {
        let inputsP2PKH: Int
        let inputsP2WPKH: Int

        let outputsP2PKH: Int
        let outputsP2WPKH: Int

        let expected: Decimal

        func size(subject: TransactionSizeCalculating) -> Decimal {
            var inputs: [UnspentOutput] = []
            var outputs: [UnspentOutput] = []

            for _ in 0..<inputsP2PKH {
                inputs.append(.createP2PKH(with: .zero(currency: .bitcoin)))
            }
            for _ in 0..<inputsP2WPKH {
                inputs.append(.createP2WPKH(with: .zero(currency: .bitcoin)))
            }

            for _ in 0..<outputsP2PKH {
                outputs.append(.createP2PKH(with: .zero(currency: .bitcoin)))
            }
            for _ in 0..<outputsP2WPKH {
                outputs.append(.createP2WPKH(with: .zero(currency: .bitcoin)))
            }

            return subject.transactionBytes(
                inputs: .init(unspentOutputs: inputs),
                outputs: .init(unspentOutputs: outputs)
            )
        }
    }

    func testRightTransactionSize() {
        let testCases: [TestCase] = [
            // 0 x 0 transactions
            TestCase(inputsP2PKH: 0, inputsP2WPKH: 0, outputsP2PKH: 0, outputsP2WPKH: 0, expected: 10),

            // 1 x 1 transactions
            TestCase(inputsP2PKH: 1, inputsP2WPKH: 0, outputsP2PKH: 1, outputsP2WPKH: 0, expected: 192),
            TestCase(inputsP2PKH: 1, inputsP2WPKH: 0, outputsP2PKH: 0, outputsP2WPKH: 1, expected: 189),

            TestCase(inputsP2PKH: 0, inputsP2WPKH: 1, outputsP2PKH: 1, outputsP2WPKH: 0, expected: 112.5),
            TestCase(inputsP2PKH: 0, inputsP2WPKH: 1, outputsP2PKH: 0, outputsP2WPKH: 1, expected: 109.5),

            // 1 x 2 transactions
            TestCase(inputsP2PKH: 1, inputsP2WPKH: 0, outputsP2PKH: 2, outputsP2WPKH: 0, expected: 226),
            TestCase(inputsP2PKH: 1, inputsP2WPKH: 0, outputsP2PKH: 0, outputsP2WPKH: 2, expected: 220),
            TestCase(inputsP2PKH: 1, inputsP2WPKH: 0, outputsP2PKH: 1, outputsP2WPKH: 1, expected: 223),

            TestCase(inputsP2PKH: 0, inputsP2WPKH: 1, outputsP2PKH: 2, outputsP2WPKH: 0, expected: 146.5),
            TestCase(inputsP2PKH: 0, inputsP2WPKH: 1, outputsP2PKH: 0, outputsP2WPKH: 2, expected: 140.5),
            TestCase(inputsP2PKH: 0, inputsP2WPKH: 1, outputsP2PKH: 1, outputsP2WPKH: 1, expected: 143.5),

            // 2 x 1 transactions
            TestCase(inputsP2PKH: 2, inputsP2WPKH: 0, outputsP2PKH: 1, outputsP2WPKH: 0, expected: 340),
            TestCase(inputsP2PKH: 2, inputsP2WPKH: 0, outputsP2PKH: 0, outputsP2WPKH: 1, expected: 337),

            TestCase(inputsP2PKH: 1, inputsP2WPKH: 1, outputsP2PKH: 1, outputsP2WPKH: 0, expected: 260.5),
            TestCase(inputsP2PKH: 1, inputsP2WPKH: 1, outputsP2PKH: 0, outputsP2WPKH: 1, expected: 257.5),

            TestCase(inputsP2PKH: 0, inputsP2WPKH: 2, outputsP2PKH: 1, outputsP2WPKH: 0, expected: 180.25),
            TestCase(inputsP2PKH: 0, inputsP2WPKH: 2, outputsP2PKH: 0, outputsP2WPKH: 1, expected: 177.25),

            // 2 x 2 transactions
            TestCase(inputsP2PKH: 2, inputsP2WPKH: 0, outputsP2PKH: 2, outputsP2WPKH: 0, expected: 374),
            TestCase(inputsP2PKH: 2, inputsP2WPKH: 0, outputsP2PKH: 1, outputsP2WPKH: 1, expected: 371),
            TestCase(inputsP2PKH: 2, inputsP2WPKH: 0, outputsP2PKH: 0, outputsP2WPKH: 2, expected: 368),

            TestCase(inputsP2PKH: 1, inputsP2WPKH: 1, outputsP2PKH: 2, outputsP2WPKH: 0, expected: 294.5),
            TestCase(inputsP2PKH: 1, inputsP2WPKH: 1, outputsP2PKH: 1, outputsP2WPKH: 1, expected: 291.5),
            TestCase(inputsP2PKH: 1, inputsP2WPKH: 1, outputsP2PKH: 0, outputsP2WPKH: 2, expected: 288.5),

            TestCase(inputsP2PKH: 0, inputsP2WPKH: 2, outputsP2PKH: 2, outputsP2WPKH: 0, expected: 214.25),
            TestCase(inputsP2PKH: 0, inputsP2WPKH: 2, outputsP2PKH: 1, outputsP2WPKH: 1, expected: 211.25),
            TestCase(inputsP2PKH: 0, inputsP2WPKH: 2, outputsP2PKH: 0, outputsP2WPKH: 2, expected: 208.25)
        ]
        for testCase in testCases {
            XCTAssertEqual(
                testCase.size(subject: subject),
                testCase.expected
            )
        }
    }

    func testDustThreshold() {
        XCTAssertEqual(
            subject.dustThreshold(for: 55, type: .P2PKH),
            10010
        )
        XCTAssertEqual(
            subject.dustThreshold(for: 55, type: .P2SH),
            18095
        )
        XCTAssertEqual(
            subject.dustThreshold(for: 55, type: .P2WPKH),
            5432
        )
        XCTAssertEqual(
            subject.dustThreshold(for: 55, type: .P2WSH),
            8113
        )
    }

    func testEffectiveBalanceNoInputNoOutput() {
        XCTAssertEqual(
            subject.effectiveBalance(for: 0, inputs: [], outputs: .zero),
            0
        )
        XCTAssertEqual(
            subject.effectiveBalance(for: 55, inputs: [], outputs: .zero),
            0
        )
    }

    func testEffectiveBalanceP2PKHInput() {
        let inputs: [UnspentOutput] = [
            .createP2PKH(with: .create(minor: 15000, currency: .bitcoin)),
            .createP2PKH(with: .create(minor: 10000, currency: .bitcoin)),
            .createP2PKH(with: .create(minor: 20000, currency: .bitcoin))
        ]
        let outputs: [UnspentOutput] = [
            .createP2PKH(with: .zero(currency: .bitcoin)),
            .createP2PKH(with: .zero(currency: .bitcoin))
        ]
        let outputQuantities = TransactionSizeCalculatorQuantities(unspentOutputs: outputs)
        XCTAssertEqual(
            subject.effectiveBalance(for: 0, inputs: inputs, outputs: outputQuantities),
            45000
        )
        // 45000 - 55 * (10 + 3*148 + 2*34) = 45000 - ceil(28710) = 16290
        XCTAssertEqual(
            subject.effectiveBalance(for: 55, inputs: inputs, outputs: outputQuantities),
            16290
        )
    }

    func testEffectiveBalanceMixedInput() {
        let inputs: [UnspentOutput] = [
            .createP2WPKH(with: .create(minor: 15000, currency: .bitcoin)),
            .createP2WPKH(with: .create(minor: 10000, currency: .bitcoin)),
            .createP2PKH(with: .create(minor: 20000, currency: .bitcoin))
        ]
        let outputs: [UnspentOutput] = [
            .createP2PKH(with: .zero(currency: .bitcoin)),
            .createP2PKH(with: .zero(currency: .bitcoin))
        ]
        let outputQuantities = TransactionSizeCalculatorQuantities(unspentOutputs: outputs)
        XCTAssertEqual(
            subject.effectiveBalance(for: 0, inputs: inputs, outputs: outputQuantities),
            45000
        )
        // 45000 - 55 * (10.75 + 2*67.75 + 148 + 2*34) = 45000 - ceil(19923.75) = 25076
        XCTAssertEqual(
            subject.effectiveBalance(for: 55, inputs: inputs, outputs: outputQuantities),
            25076
        )
    }

    func testEffectiveBalanceP2WPKHInput() {
        let inputs: [UnspentOutput] = [
            .createP2WPKH(with: .create(minor: 15000, currency: .bitcoin)),
            .createP2WPKH(with: .create(minor: 10000, currency: .bitcoin)),
            .createP2WPKH(with: .create(minor: 20000, currency: .bitcoin))
        ]
        let outputs: [UnspentOutput] = [
            .createP2PKH(with: .zero(currency: .bitcoin)),
            .createP2PKH(with: .zero(currency: .bitcoin))
        ]
        let outputQuantities = TransactionSizeCalculatorQuantities(unspentOutputs: outputs)
        XCTAssertEqual(
            subject.effectiveBalance(for: 0, inputs: inputs, outputs: outputQuantities),
            45000
        )
        // 45000 - 55 * (10.75 + 3*67.75 + 2*34) = 45000 - ceil(15510) = 29490
        XCTAssertEqual(
            subject.effectiveBalance(for: 55, inputs: inputs, outputs: outputQuantities),
            29490
        )
    }
}
