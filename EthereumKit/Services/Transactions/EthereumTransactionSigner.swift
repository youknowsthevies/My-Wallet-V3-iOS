//
//  EthereumTransactionSigner.swift
//  EthereumKit
//
//  Created by Jack on 23/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import PlatformKit
import RxSwift
import ToolKit
import WalletCore

public enum EthereumTransactionSignerError: Error {
    case incorrectChainId
}

protocol EthereumTransactionSignerAPI {

    func sign(
        transaction: EthereumTransactionCandidateCosted,
        keyPair: EthereumKeyPair
    ) -> Result<EthereumTransactionCandidateSigned, EthereumTransactionSignerError>
}

final class EthereumTransactionSigner: EthereumTransactionSignerAPI {

    func sign(
        transaction: EthereumTransactionCandidateCosted,
        keyPair: EthereumKeyPair
    ) -> Result<EthereumTransactionCandidateSigned, EthereumTransactionSignerError> {
        var input = transaction.transaction
        input.privateKey = keyPair.privateKey.data
        let output: EthereumSigningOutput = AnySigner.sign(input: input, coin: .ethereum)
        let signed = EthereumTransactionCandidateSigned(transaction: output)
        return .success(signed)
    }
}
