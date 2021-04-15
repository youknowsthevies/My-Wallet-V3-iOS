//
//  EthereumTransactionSignerMock.swift
//  EthereumKitTests
//
//  Created by Jack on 14/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
@testable import EthereumKit
import Foundation
import PlatformKit

class EthereumTransactionSignerMock: EthereumTransactionSignerAPI {
    var lastTransactionForSignature: EthereumTransactionCandidateCosted?
    var lastKeyPair: EthereumKeyPair?

    var signTransactionResult:  Result<EthereumTransactionCandidateSigned, EthereumTransactionSignerError> = Result.failure(.incorrectChainId)

    func sign(
        transaction: EthereumTransactionCandidateCosted,
        keyPair: EthereumKeyPair
    ) -> Result<EthereumTransactionCandidateSigned, EthereumTransactionSignerError> {
        lastTransactionForSignature = transaction
        lastKeyPair = keyPair
        return signTransactionResult
    }

}
