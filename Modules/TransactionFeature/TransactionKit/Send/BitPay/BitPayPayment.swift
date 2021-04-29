// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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
