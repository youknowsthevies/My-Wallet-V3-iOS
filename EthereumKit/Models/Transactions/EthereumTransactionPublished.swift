//
//  EthereumTransactionPublished.swift
//  EthereumKit
//
//  Created by Jack on 14/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import PlatformKit

enum EthereumTransactionPublishedError: Error {
    case invalidResponseHash
}

public struct EthereumTransactionPublished: Equatable {
    public let transactionHash: String
    
    init(finalisedTransaction: EthereumTransactionFinalised, responseHash: String) throws {
        guard finalisedTransaction.transactionHash == responseHash else {
            throw EthereumTransactionPublishedError.invalidResponseHash
        }
        self.init(
            finalisedTransaction: finalisedTransaction,
            transactionHash: finalisedTransaction.transactionHash
        )
    }
    
    init(finalisedTransaction: EthereumTransactionFinalised, transactionHash: String) {
        self.transactionHash = transactionHash
    }
}
