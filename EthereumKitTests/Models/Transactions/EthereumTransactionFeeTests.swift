//
//  EthereumTransactionFeeTests.swift
//  EthereumKitTests
//
//  Created by Paulo on 29/01/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import EthereumKit
import PlatformKit
import XCTest

class EthereumTransactionFeeTests: XCTestCase {

    var sut: EthereumTransactionFee!
    
    override func setUp() {
        sut = EthereumTransactionFee(
            limits: TransactionFeeLimits(min: 1, max: 3),
            regular: 5,
            priority: 7,
            gasLimit: 11,
            gasLimitContract: 13
        )
    }

    func testAbsoluteFee() {
        XCTAssertEqual(sut.absoluteFee(with: .regular, isContract: false), CryptoValue.ether(minor: "55000000000"))
        XCTAssertEqual(sut.absoluteFee(with: .regular, isContract: true), CryptoValue.ether(minor: "65000000000"))
        XCTAssertEqual(sut.absoluteFee(with: .priority, isContract: false), CryptoValue.ether(minor: "77000000000"))
        XCTAssertEqual(sut.absoluteFee(with: .priority, isContract: true), CryptoValue.ether(minor: "91000000000"))
    }
}
