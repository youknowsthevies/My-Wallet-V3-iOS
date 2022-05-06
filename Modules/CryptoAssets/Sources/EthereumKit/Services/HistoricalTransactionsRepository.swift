// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkError

public protocol HistoricalTransactionsRepositoryAPI {
    func transaction(
        identifier: String
    ) -> AnyPublisher<EthereumHistoricalTransaction, NetworkError>

    func transactions(
        address: String
    ) -> AnyPublisher<[EthereumHistoricalTransaction], NetworkError>
}
