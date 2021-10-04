// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import EthereumKit
import NetworkError
import PlatformKit

class TransactionClientAPIMock: TransactionClientAPI {

    var latestBlockValue: AnyPublisher<LatestBlockResponse, NetworkError> =
        .failure(.authentication(EthereumAPIClientMockError.mockError))
    var latestBlock: AnyPublisher<LatestBlockResponse, NetworkError> {
        latestBlockValue
    }

    var transactionValue: AnyPublisher<EthereumHistoricalTransactionResponse, NetworkError> =
        .failure(.authentication(EthereumAPIClientMockError.mockError))

    func transaction(
        with hash: String
    ) -> AnyPublisher<EthereumHistoricalTransactionResponse, NetworkError> {
        transactionValue
    }

    var lastTransactionsForAccount: String?
    var transactionsForAccountValue: AnyPublisher<[EthereumHistoricalTransactionResponse], NetworkError> =
        .just([])

    func transactions(for account: String) -> AnyPublisher<[EthereumHistoricalTransactionResponse], NetworkError> {
        lastTransactionsForAccount = account
        return transactionsForAccountValue
    }
}
