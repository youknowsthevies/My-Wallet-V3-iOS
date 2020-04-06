//
//  EthereumTransactionCandidateCostedBuilder.swift
//  BlockchainTests
//
//  Created by Paulo on 06/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import web3swift
import BigInt
import TestKit
@testable import EthereumKit

class EthereumTransactionCandidateCostedBuilder {

    var web3swiftTransaction: web3swift.EthereumTransaction?

    var candidate: EthereumTransactionCandidate? {
        didSet {
            candidateUpdated()
        }
    }

    init(candidate: EthereumTransactionCandidate = EthereumTransactionCandidateBuilder().build()!) {
        self.candidate = candidate
        candidateUpdated()
    }

    func with(candidate: EthereumTransactionCandidate) -> Self {
        self.candidate = candidate
        candidateUpdated()
        return self
    }

    func with(web3swiftTransaction: web3swift.EthereumTransaction) -> Self {
        self.web3swiftTransaction = web3swiftTransaction
        return self
    }

    func build() -> EthereumTransactionCandidateCosted? {
        guard let web3swiftTransaction = web3swiftTransaction else {
            return nil
        }
        return try? EthereumTransactionCandidateCosted(
            transaction: web3swiftTransaction
        )
    }

    private func candidateUpdated() {
        web3swiftTransaction = web3swift.EthereumTransaction(
            candidate: candidate!
        )
    }
}

extension web3swift.EthereumTransaction {
    init(candidate: EthereumTransactionCandidate, nonce: BigUInt = 9) {
        self.init(
            nonce: nonce,
            gasPrice: candidate.gasPrice,
            gasLimit: candidate.gasLimit,
            to: candidate.to.web3swiftAddress,
            value: candidate.value,
            data: candidate.data ?? Data()
        )
        self.UNSAFE_setChainID(NetworkId.mainnet)
    }
}
