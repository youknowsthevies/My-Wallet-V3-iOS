//
//  EtherTransaction+Extensions.swift
//  Blockchain
//
//  Created by Jack on 29/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import EthereumKit
import PlatformKit

extension EtherTransaction {
    enum TxType: String {
        case sent
        case received
        case transfer
        
        var platformDirection: PlatformKit.Direction {
            switch self {
            case .received:
                return .credit
            case .sent:
                return .debit
            case .transfer:
                return .transfer
            }
        }
    }
    
    convenience init(transaction: EthereumHistoricalTransaction?) {
        self.init()
        
        guard let transaction = transaction else { return }
        
        self.amount = transaction.amount
        self.amountTruncated = EtherTransaction.truncated(amount: transaction.amount)
        let transactionFee = transaction.fee ?? CryptoValue.etherFromGwei(string: "0")
        self.fee = transactionFee?.toDisplayString(includeSymbol: false)
        self.from = transaction.fromAddress.publicKey
        self.to = transaction.toAddress.publicKey
        self.myHash = transaction.transactionHash
        self.note = transaction.memo
        self.txType = transaction.direction.txType.rawValue
        self.time = UInt64(transaction.createdAt.timeIntervalSince1970)
        self.confirmations = transaction.confirmations
        self.fiatAmountsAtTime = [:]
    }
}

extension EthereumHistoricalTransaction {
    var legacyTransaction: EtherTransaction? {
        EtherTransaction(transaction: self)
    }
}

extension PlatformKit.Direction {
    var txType: EtherTransaction.TxType {
        switch self {
        case .credit:
            return .received
        case .debit:
            return .sent
        case .transfer:
            return .transfer
        }
    }
}
