// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import EthereumKit
import Foundation
import PlatformKit

class EthereumSignerMock: EthereumSignerAPI {

    var lastTransactionForSignature: EthereumTransactionCandidateCosted?
    var lastKeyPair: EthereumKeyPair?

    typealias SignTransactionResult = Result<EthereumTransactionCandidateSigned, EthereumSignerError>

    var signTransactionResult: SignTransactionResult = .failure(.incorrectChainId)

    func sign(
        transaction: EthereumTransactionCandidateCosted,
        keyPair: EthereumKeyPair
    ) -> Result<EthereumTransactionCandidateSigned, EthereumSignerError> {
        lastTransactionForSignature = transaction
        lastKeyPair = keyPair
        return signTransactionResult
    }

    func sign(messageData: Data, keyPair: EthereumKeyPair) -> Result<Data, EthereumSignerError> {
        .failure(.incorrectChainId)
    }
}
