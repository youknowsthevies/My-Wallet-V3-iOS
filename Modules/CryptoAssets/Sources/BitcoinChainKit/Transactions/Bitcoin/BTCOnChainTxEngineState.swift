// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct BTCOnChainTxEngineState<Token: BitcoinChainToken> {

    private(set) var transactionCandidate: NativeBitcoinTransactionCandidate?

    private(set) var context: NativeBitcoinTransactionContext?

    init(
        transactionCandidate: NativeBitcoinTransactionCandidate? = nil,
        context: NativeBitcoinTransactionContext? = nil
    ) {
        self.transactionCandidate = transactionCandidate
        self.context = context
    }

    mutating func add(transactionCandidate: NativeBitcoinTransactionCandidate) {
        self.transactionCandidate = transactionCandidate
    }

    mutating func add(context: NativeBitcoinTransactionContext) {
        self.context = context
    }
}
