// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import BitcoinChainKit
import MoneyKit
import PlatformKit
import XCTest

final class UnspentOutputOutputTypeTests: XCTestCase {

    func testShouldReturnP2PKH() {
        XCTAssertEqual(
            UnspentOutput.create(
                with: CryptoValue.create(minor: 15000, currency: .bitcoin),
                script: "76a914641ad5051edd97029a003fe9efb29359fcee409d88ac"
            ).scriptType,
            .P2PKH
        )
    }

    func testShouldReturnP2WPKH() {
        XCTAssertEqual(
            UnspentOutput.create(
                with: CryptoValue.create(minor: 15000, currency: .bitcoin),
                script: "0014326e987644fa2d8ddf813ad40aa09b9b1229b71f"
            ).scriptType,
            .P2WPKH
        )
    }
}
