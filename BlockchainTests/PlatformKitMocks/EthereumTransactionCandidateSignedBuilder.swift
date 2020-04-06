//
//  EthereumTransactionCandidateSignedBuilder.swift
//  BlockchainTests
//
//  Created by Paulo on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import web3swift
@testable import EthereumKit

class EthereumTransactionCandidateSignedBuilder {
    var costed: EthereumTransactionCandidateCosted? {
        didSet {
            web3swiftTransaction = costed?.transaction
        }
    }

    var web3swiftTransaction: web3swift.EthereumTransaction?

    var candidate: EthereumTransactionCandidate? {
        didSet {
            candidateUpdated()
        }
    }

    init() {}

    init(candidate: EthereumTransactionCandidate) {
        self.candidate = candidate
        candidateUpdated()
    }

    func with(costed: EthereumTransactionCandidateCosted) -> Self {
        self.costed = costed
        return self
    }

    func with(web3swiftTransaction: web3swift.EthereumTransaction) -> Self {
        self.web3swiftTransaction = web3swiftTransaction
        return self
    }

    func build() -> EthereumTransactionCandidateSigned? {
        guard var transaction = web3swiftTransaction else {
            return nil
        }

        let privateKeyData = MockEthereumWalletTestData.privateKeyData

        transaction.nonce = MockEthereumWalletTestData.Transaction.nonce

        // swiftlint:disable force_try
        try! Web3Signer.EIP155Signer.sign(transaction: &transaction, privateKey: privateKeyData, useExtraEntropy: false)
        // swiftlint:enable force_try

        return try? EthereumTransactionCandidateSigned(
            transaction: transaction
        )
    }

    private func candidateUpdated() {
        let costed = EthereumTransactionCandidateCostedBuilder()
            .with(candidate: candidate!)
            .build()!
        self.costed = costed
    }

}
