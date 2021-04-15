//
//  BitPayPayment.swift
//  TransactionKit
//
//  Created by Alex McGregor on 4/7/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

struct BitPayPayment: Encodable {
    let chain: String
    let transactions: [Transaction]
    
    struct Transaction: Encodable {
        let tx: String
        let weightedSize: Int
    }
    
    init(chain: String, transactions: [Transaction]) {
        self.chain = chain
        self.transactions = transactions
    }
}
