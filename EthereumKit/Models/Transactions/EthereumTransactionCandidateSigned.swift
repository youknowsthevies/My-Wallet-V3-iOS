//
//  EthereumTransactionCandidateSigned.swift
//  EthereumKit
//
//  Created by Jack on 14/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import PlatformKit
import WalletCore

public struct EthereumTransactionCandidateSigned {
    public let transactionHash: String
    let encodedTransaction: Data

    init(transaction: WalletCore.EthereumSigningOutput) {
        self.init(encodedTransaction: transaction.encoded)
    }

    init(encodedTransaction: Data) {
        self.transactionHash = Hash.keccak256(data: encodedTransaction).hexString.withHex
        self.encodedTransaction = encodedTransaction
    }
}
