//
//  EthereumTransactionCandidateMockBuilder.swift
//  EthereumKitTests
//
//  Created by Jack on 19/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import web3swift
import BigInt
@testable import EthereumKit

class EthereumTransactionPublishedBuilder {

    var finalised: EthereumTransactionFinalised? =
        EthereumTransactionFinalisedBuilder().build()

    var candidate: EthereumTransactionCandidate? {
        didSet {
            candidateUpdated()
        }
    }

    var transactionHash: String?

    init(candidate: EthereumTransactionCandidate = EthereumTransactionCandidateBuilder().build()!) {
        self.candidate = candidate
        candidateUpdated()
    }

    func with(candidate: EthereumTransactionCandidate) -> Self {
        self.candidate = candidate
        candidateUpdated()
        return self
    }

    func with(finalised: EthereumTransactionFinalised) -> Self {
        self.finalised = finalised
        return self
    }

    func with(transactionHash: String) -> Self {
        self.transactionHash = transactionHash
        return self
    }

    func build() -> EthereumTransactionPublished? {
        guard let finalised = finalised else {
            return nil
        }
        guard let transactionHash = transactionHash else {
            return EthereumTransactionPublished(
                finalisedTransaction: finalised,
                transactionHash: finalised.transactionHash
            )
        }
        return EthereumTransactionPublished(
            finalisedTransaction: finalised,
            transactionHash: transactionHash
        )
    }

    private func candidateUpdated() {
        let costed = EthereumTransactionCandidateCostedBuilder()
            .with(candidate: candidate!)
            .build()!
        let signed = EthereumTransactionCandidateSignedBuilder()
            .with(costed: costed)
            .build()!
        let finalised = EthereumTransactionFinalisedBuilder()
            .with(signed: signed)
            .build()!
        self.finalised = finalised
    }
}
