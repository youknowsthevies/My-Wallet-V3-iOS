// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import EthereumKit

class EthereumTransactionFinalisedBuilder {

    var signed: EthereumTransactionCandidateSigned?
    var candidate: EthereumTransactionCandidate? {
        didSet {
            candidateUpdated()
        }
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

    func build() -> EthereumTransactionFinalised? {
        guard let signed = self.signed else {
            return nil
        }
        return EthereumTransactionFinalised(transaction: signed)
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
