// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import EthereumKit
import Foundation

class EthereumTransactionPublishedBuilder {
    
    var finalised: EthereumTransactionFinalised?
    var candidate: EthereumTransactionCandidate? {
        didSet {
            candidateUpdated()
        }
    }

    func with(candidate: EthereumTransactionCandidate) -> Self {
        self.candidate = candidate
        return self
    }

    func build() -> EthereumTransactionPublished? {
        guard let finalised = finalised else {
            return nil
        }
        return EthereumTransactionPublished(
            finalisedTransaction: finalised,
            transactionHash: finalised.transactionHash
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
