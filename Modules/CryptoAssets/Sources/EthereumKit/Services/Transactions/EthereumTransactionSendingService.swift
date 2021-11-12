// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import PlatformKit
import RxSwift

public enum EthereumTransactionSendingServiceError: Error {
    case generic
    case errorSigningTransaction(Error)
    case pushTransactionFailed(Error)
    case pushTransactionMalformed(EthereumTransactionPublishedError)
    case failedAccountNonce(Error)
}

protocol EthereumTransactionSendingServiceAPI {
    func signAndSend(
        transaction: EthereumTransactionCandidate,
        keyPair: EthereumKeyPair
    ) -> AnyPublisher<EthereumTransactionPublished, EthereumTransactionSendingServiceError>
}

final class EthereumTransactionSendingService: EthereumTransactionSendingServiceAPI {

    private let accountDetailsService: EthereumAccountDetailsServiceAPI
    private let client: TransactionPushClientAPI
    private let feeService: EthereumFeeServiceAPI
    private let transactionBuilder: EthereumTransactionBuilderAPI
    private let transactionSigner: EthereumSignerAPI
    private let transactionEncoder: EthereumTransactionEncoderAPI

    init(
        accountDetailsService: EthereumAccountDetailsServiceAPI = resolve(),
        client: TransactionPushClientAPI = resolve(),
        feeService: EthereumFeeServiceAPI = resolve(),
        transactionBuilder: EthereumTransactionBuilderAPI = resolve(),
        transactionSigner: EthereumSignerAPI = resolve(),
        transactionEncoder: EthereumTransactionEncoderAPI = resolve()
    ) {
        self.accountDetailsService = accountDetailsService
        self.client = client
        self.feeService = feeService
        self.transactionBuilder = transactionBuilder
        self.transactionSigner = transactionSigner
        self.transactionEncoder = transactionEncoder
    }

    func signAndSend(
        transaction: EthereumTransactionCandidate,
        keyPair: EthereumKeyPair
    ) -> AnyPublisher<EthereumTransactionPublished, EthereumTransactionSendingServiceError> {
        sign(transaction: transaction, keyPair: keyPair)
            .flatMap { [send] finalised in
                send(finalised)
            }
            .eraseToAnyPublisher()
    }

    private func sign(
        transaction: EthereumTransactionCandidate,
        keyPair: EthereumKeyPair
    ) -> AnyPublisher<EthereumTransactionFinalised, EthereumTransactionSendingServiceError> {
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
    ) -> Result<EthereumTransactionFinalised, EthereumTransactionSendingServiceError> {
        transactionBuilder
            .build(transaction: transaction, nonce: BigUInt(nonce))
            .eraseError()
            .flatMap { costed in
                transactionSigner.sign(transaction: costed, keyPair: keyPair)
                    .eraseError()
            }
            .flatMap { signed in
                transactionEncoder.encode(signed: signed)
                    .eraseError()
            }
            .mapError(EthereumTransactionSendingServiceError.errorSigningTransaction)
    }

    private func defaultAccountNonce() -> AnyPublisher<UInt64, EthereumTransactionSendingServiceError> {
        accountDetailsService.accountDetails()
            .map(\.nonce)
            .asPublisher()
            .mapError(EthereumTransactionSendingServiceError.failedAccountNonce)
            .eraseToAnyPublisher()
    }

    private func send(
        transaction: EthereumTransactionFinalised
    ) -> AnyPublisher<EthereumTransactionPublished, EthereumTransactionSendingServiceError> {
        client.push(transaction: transaction)
            .mapError(EthereumTransactionSendingServiceError.pushTransactionFailed)
            .flatMap { response in
                EthereumTransactionPublished.create(
                    finalisedTransaction: transaction,
                    responseHash: response.txHash
                )
                .publisher
                .mapError(EthereumTransactionSendingServiceError.pushTransactionMalformed)
            }
            .eraseToAnyPublisher()
    }
}
