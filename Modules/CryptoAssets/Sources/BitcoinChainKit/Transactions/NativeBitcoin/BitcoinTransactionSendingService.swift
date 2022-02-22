// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureTransactionDomain
import ToolKit

public enum BitcoinTransactionSendingServiceError: Error {}

public protocol BitcoinTransactionSendingServiceAPI {

    /// When payment transactions are created and signed, they have to pushed to the bitcoin network
    /// To push a bitcoin transaction to the bitcoin network
    /// - Parameters:
    ///  - signedTx: A signed bitcoin payment transaction ready to be pushed
    /// - Returns:
    ///  - An `AnyPublisher` that emits the send transaction hash or an error
    func send(
        encoded: SignedBitcoinChainTransaction
    ) -> AnyPublisher<String, BitcoinTransactionSendingServiceError>
}

final class BitcoinTransactionSendingService: BitcoinTransactionSendingServiceAPI {

    func send(
        encoded: SignedBitcoinChainTransaction
    ) -> AnyPublisher<String, BitcoinTransactionSendingServiceError> {
        /*
          TODO: Implementation
          1. Implement the push tx API client (from javascript)
          2. Push the tx using the API client
         */
        unimplemented()
    }
}
