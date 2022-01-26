// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
@testable import MetadataKit
import XCTest

final class DeserializeMetadataNodeTests: XCTestCase {

    func test_deserialiseNodes() throws {

        struct TestValue {

            struct Input {
                let xpriv: String
            }

            struct Output {
                let address: String
                let chainCodeHex: String
                let index: UInt32
                let wifCompressed: String
                let rawHex: String
            }

            let input: Input
            let expected: Output
        }

        let testEnvironment = TestEnvironment()

        let testValues = [
            TestValue(
                input: TestValue.Input(
                    xpriv: testEnvironment.metadataNodeXPriv
                ),
                expected: TestValue.Output(
                    address: "1Cu99U8Lux5VDvaL52A4F9GdsurkX2Cjyo",
                    chainCodeHex: "19b8bc74692c609012f4b21060a557a099bb82d90dae1871f6853b17f7d2fca3",
                    index: 382404480,
                    wifCompressed: "KyvmTTzBiwVbQFFhKfbb15x4JMvs2axc3ugbqikFsfCAekXCekyj",
                    rawHex: "50cbb7bab7eaf99bd40d450c87f02578311765ed9f001e6ef157e97e08cdf531"
                )
            )
        ]

        func runTest(for value: TestValue) throws {
            let privateKey = try deserializeMetadataNode(node: value.input.xpriv)
                .get()
            XCTAssertEqual(privateKey.address, value.expected.address)
            XCTAssertEqual(privateKey.chainCode.hex, value.expected.chainCodeHex)
            XCTAssertEqual(privateKey.index, value.expected.index)
            XCTAssertEqual(privateKey.wifCompressed(), value.expected.wifCompressed)
            XCTAssertEqual(privateKey.raw.hex, value.expected.rawHex)
        }

        for value in testValues {
            try runTest(for: value)
        }
    }
}
