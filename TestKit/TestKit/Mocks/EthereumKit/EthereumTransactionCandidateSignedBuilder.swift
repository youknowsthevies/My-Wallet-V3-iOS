// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import EthereumKit

class EthereumTransactionCandidateSignedBuilder {

    var costed: EthereumTransactionCandidateCosted?
    private let signer = EthereumTransactionSigner()

    func with(costed: EthereumTransactionCandidateCosted) -> Self {
        self.costed = costed
        return self
    }

    func build() -> EthereumTransactionCandidateSigned? {
        guard let costed = self.costed else {
            return nil
        }
        let result = signer.sign(transaction: costed, keyPair: MockEthereumWalletTestData.keyPair)
        guard case let .success(signed) = result else {
            return nil
        }
        return signed
    }
}
