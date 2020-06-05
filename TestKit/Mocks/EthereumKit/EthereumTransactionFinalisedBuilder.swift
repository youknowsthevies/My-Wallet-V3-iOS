//
//  EthereumTransactionCandidateMockBuilder.swift
//  EthereumKitTests
//
//  Created by Jack on 19/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import web3swift
@testable import EthereumKit

class EthereumTransactionFinalisedBuilder {
    var signed: EthereumTransactionCandidateSigned? {
        didSet {
            web3swiftTransaction = signed?.transaction
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

    func with(candidate: EthereumTransactionCandidate) -> Self {
        self.candidate = candidate
        candidateUpdated()
        return self
    }

    func with(signed: EthereumTransactionCandidateSigned) -> Self {
        self.signed = signed
        return self
    }

    func with(web3swiftTransaction: web3swift.EthereumTransaction) -> Self {
        self.web3swiftTransaction = web3swiftTransaction
        return self
    }

    func build() -> EthereumTransactionFinalised? {
        guard let web3swiftTransaction = web3swiftTransaction else {
            return nil
        }
        guard let encodedData = web3swiftTransaction.encode() else {
            return nil
        }
        let rawTxHexString = encodedData.hex.withHex.lowercased()
        return EthereumTransactionFinalised(
            transaction: web3swiftTransaction,
            rawTx: rawTxHexString
        )
    }

    private func candidateUpdated() {
        let costed = EthereumTransactionCandidateCostedBuilder()
            .with(candidate: candidate!)
            .build()!
        let signed = EthereumTransactionCandidateSignedBuilder()
            .with(costed: costed)
            .build()
        self.signed = signed
    }
}
