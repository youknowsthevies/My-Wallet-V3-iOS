// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import PlatformKit
import RxSwift

public enum EthereumTransactionSendingServiceError: Error {
    case pushTransactionFailed(Error)
    case pushTransactionMalformed(EthereumTransactionPublishedError)
    case signingError(EthereumTransactionSigningServiceError)
}

protocol EthereumTransactionSendingServiceAPI {
    func signAndSend(
        transaction: EthereumTransactionCandidate,
        keyPair: EthereumKeyPair
    ) -> AnyPublisher<EthereumTransactionPublished, EthereumTransactionSendingServiceError>
}

final class EthereumTransactionSendingService: EthereumTransactionSendingServiceAPI {

    private let client: TransactionPushClientAPI
    private let transactionSigner: EthereumTransactionSigningServiceAPI

    init(
        client: TransactionPushClientAPI = resolve(),
        transactionSigner: EthereumTransactionSigningServiceAPI = resolve()
    ) {
        self.client = client
        self.transactionSigner = transactionSigner
    }

    func signAndSend(
        transaction: EthereumTransactionCandidate,
        keyPair: EthereumKeyPair
    ) -> AnyPublisher<EthereumTransactionPublished, EthereumTransactionSendingServiceError> {
        transactionSigner
            .sign(transaction: transaction, keyPair: keyPair)
            .mapError(EthereumTransactionSendingServiceError.signingError)
            .flatMap { [send] finalised in
                send(finalised)
            }
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
