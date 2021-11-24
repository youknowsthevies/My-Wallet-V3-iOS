// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import PlatformKit
import RxSwift

public enum EthereumTransactionSigningServiceError: TransactionValidationError {
    case failedAccountNonce(Error)
    case errorSigningTransaction(Error)
}

protocol EthereumTransactionSigningServiceAPI {
    func sign(
        transaction: EthereumTransactionCandidate,
        keyPair: EthereumKeyPair
    ) -> AnyPublisher<EthereumTransactionFinalised, EthereumTransactionSigningServiceError>
}

final class EthereumTransactionSigningService: EthereumTransactionSigningServiceAPI {

    private let accountDetailsService: EthereumAccountDetailsServiceAPI
    private let transactionSigner: EthereumSignerAPI
    private let transactionEncoder: EthereumTransactionEncoderAPI

    init(
        accountDetailsService: EthereumAccountDetailsServiceAPI = resolve(),
        transactionSigner: EthereumSignerAPI = resolve(),
        transactionEncoder: EthereumTransactionEncoderAPI = resolve()
    ) {
        self.accountDetailsService = accountDetailsService
        self.transactionSigner = transactionSigner
        self.transactionEncoder = transactionEncoder
    }

    func sign(
        transaction: EthereumTransactionCandidate,
        keyPair: EthereumKeyPair
    ) -> AnyPublisher<EthereumTransactionFinalised, EthereumTransactionSigningServiceError> {
        defaultAccountNonce()
            .flatMap { [buildSignEncode] nonce in
                buildSignEncode(transaction, nonce, keyPair)
                    .publisher
            }
            .eraseToAnyPublisher()
    }

    private func buildSignEncode(
        transaction: EthereumTransactionCandidate,
        nonce: UInt64,
        keyPair: EthereumKeyPair
    ) -> Result<EthereumTransactionFinalised, EthereumTransactionSigningServiceError> {
        EthereumTransactionCandidateCosted
            .create(transaction: transaction, nonce: BigUInt(nonce))
            .eraseError()
            .flatMap { costed in
                transactionSigner.sign(transaction: costed, keyPair: keyPair)
                    .eraseError()
            }
            .flatMap { signed in
                transactionEncoder.encode(signed: signed)
                    .eraseError()
            }
            .mapError(EthereumTransactionSigningServiceError.errorSigningTransaction)
    }

    private func defaultAccountNonce() -> AnyPublisher<UInt64, EthereumTransactionSigningServiceError> {
        accountDetailsService.accountDetails()
            .map(\.nonce)
            .asPublisher()
            .mapError(EthereumTransactionSigningServiceError.failedAccountNonce)
            .eraseToAnyPublisher()
    }
}
