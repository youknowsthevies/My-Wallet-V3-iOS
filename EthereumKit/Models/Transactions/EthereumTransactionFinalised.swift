//
//  EthereumTransactionFinalised.swift
//  EthereumKit
//
//  Created by Jack on 14/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

public struct EthereumTransactionFinalised: Equatable {
    
    public let transactionHash: String
    public let rawTransaction: String
    
    init(transaction: EthereumTransactionCandidateSigned) {
        transactionHash = transaction.transactionHash
        rawTransaction = transaction.encodedTransaction.hexValue.withHex.lowercased()
    }
}
