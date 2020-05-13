//
//  EtherTransactionTests.swift
//  BlockchainTests
//
//  Created by Jack on 22/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import PlatformKit
import EthereumKit
@testable import Blockchain

class EtherTransactionTests: XCTestCase {
    let fromAddress = EthereumAddress(stringLiteral: "0x0000000000000000000000000000000000000000")
    let toAddress = EthereumAddress(stringLiteral: "0x0000000000000000000000000000000000000001")
    func test_conversion() {
        let transaction = EthereumHistoricalTransaction(
            identifier: "transactionHash",
            fromAddress: fromAddress,
            toAddress: toAddress,
            direction: .credit,
            amount: "0.09888244",
            transactionHash: "transactionHash",
            createdAt: Date(),
            fee: CryptoValue.etherFromGwei(string: "231000"),
            memo: "memo",
            confirmations: 12,
            state: .confirmed
        )
        
        XCTAssertTrue(transaction.isConfirmed)
        
        let etherTransaction = transaction.legacyTransaction!
        
        XCTAssertEqual(etherTransaction.amount!, "0.09888244")
        XCTAssertEqual(etherTransaction.amountTruncated!, "0.09888244")
        XCTAssertEqual(etherTransaction.fee!, "0.000231")
        XCTAssertEqual(etherTransaction.from!, "0x0000000000000000000000000000000000000000")
        XCTAssertEqual(etherTransaction.to!, "0x0000000000000000000000000000000000000001")
        XCTAssertEqual(etherTransaction.myHash!, "transactionHash")
        XCTAssertEqual(etherTransaction.note!, "memo")
        XCTAssertEqual(etherTransaction.txType!, "received")
        XCTAssertEqual(etherTransaction.time, UInt64(transaction.createdAt.timeIntervalSince1970))
        XCTAssertEqual(etherTransaction.confirmations, 12)
        XCTAssertEqual(etherTransaction.fiatAmountsAtTime!.count, 0)
    }
}
