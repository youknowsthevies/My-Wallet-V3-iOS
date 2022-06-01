// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
@testable import EthereumKit
import PlatformKit

final class TransactionPushClientAPIMock: TransactionPushClientAPI {

    var lastPushedTransaction: EthereumTransactionEncoded?
    var pushTransactionResult: AnyPublisher<EthereumPushTxResponse, NetworkError>!
    var evmPushTransactionResult: AnyPublisher<EVMPushTxResponse, NetworkError>!

    func push(
        transaction: EthereumTransactionEncoded
    ) -> AnyPublisher<EthereumPushTxResponse, NetworkError> {
        lastPushedTransaction = transaction
        return pushTransactionResult
    }

    func evmPush(
        transaction: EthereumTransactionEncoded,
        network: EVMNetwork
    ) -> AnyPublisher<EVMPushTxResponse, NetworkError> {
        lastPushedTransaction = transaction
        return evmPushTransactionResult
    }
}
