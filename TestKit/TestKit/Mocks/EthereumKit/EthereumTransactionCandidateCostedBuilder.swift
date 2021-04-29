// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import EthereumKit

class EthereumTransactionCandidateCostedBuilder {

    var candidate: EthereumTransactionCandidate?
    private let builder = EthereumTransactionBuilder()

    init(candidate: EthereumTransactionCandidate = EthereumTransactionCandidateBuilder().build()!) {
        self.candidate = candidate
    }

    func with(candidate: EthereumTransactionCandidate) -> Self {
        self.candidate = candidate
        return self
    }

    func build() -> EthereumTransactionCandidateCosted? {
        guard let candidate = candidate else {
            return nil
        }
        let builder = EthereumTransactionBuilder()
        let result = builder.build(transaction: candidate, nonce: MockEthereumWalletTestData.Transaction.nonce)
        guard case let .success(costed) = result else {
            return nil
        }
        return costed
    }
}
