// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureTransactionDomain
import ToolKit

public enum BitcoinTransactionSendingServiceError: Error {}

public protocol BitcoinTransactionSendingServiceAPI {

    func sign(
        with secondPassword: String?
    ) -> AnyPublisher<EngineTransaction, BitcoinTransactionSendingServiceError>

    func send(
        coin: BitcoinChainCoin,
        with secondPassword: String?
    ) -> AnyPublisher<String, BitcoinTransactionSendingServiceError>
}

final class BitcoinTransactionSendingService: BitcoinTransactionSendingServiceAPI {

    func sign(
        with secondPassword: String?
    ) -> AnyPublisher<EngineTransaction, BitcoinTransactionSendingServiceError> {
        unimplemented()
    }

    func send(
        coin: BitcoinChainCoin,
        with secondPassword: String?
    ) -> AnyPublisher<String, BitcoinTransactionSendingServiceError> {
        unimplemented()
    }
}
