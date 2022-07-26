// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import FeatureTransactionDomain
import ToolKit

protocol BitcoinTransactionSendingServiceAPI {

    /// When payment transactions are created and signed, they have to pushed to the bitcoin network
    /// To push a bitcoin transaction to the bitcoin network
    /// - Parameters:
    ///  - signedTransaction: A signed bitcoin payment transaction ready to be pushed
    /// - Returns:
    ///  - An `AnyPublisher` that emits the send transaction hash or an error
    func send(
        signedTransaction: NativeSignedBitcoinTransaction
    ) -> AnyPublisher<String, NetworkError>
}

final class BitcoinTransactionSendingService: BitcoinTransactionSendingServiceAPI {

    private let client: APIClientAPI

    init(client: APIClientAPI) {
        self.client = client
    }

    func send(
        signedTransaction: NativeSignedBitcoinTransaction
    ) -> AnyPublisher<String, NetworkError> {
        client.push(transaction: signedTransaction.encoded)
            .replaceOutput(with: signedTransaction.txHash)
            .eraseToAnyPublisher()
    }
}

extension NativeSignedBitcoinTransaction {

    fileprivate var encoded: EncodedBitcoinChainTransaction {
        EncodedBitcoinChainTransaction(
            encodedTx: encodedMsg,
            replayProtectionLockSecret: replayProtectionLockSecret
        )
    }
}
