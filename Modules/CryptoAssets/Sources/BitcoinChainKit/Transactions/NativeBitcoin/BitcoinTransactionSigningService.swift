// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureTransactionDomain
import ToolKit

public enum BitcoinTransactionSigningServiceError: Error {}

public protocol BitcoinTransactionSigningServiceAPI {

    /// A signature verification is required for every bitcoin transaction
    /// To sign a bitcoin payment candidate, and return a signed transaction
    /// - Parameters:
    ///   - candidate: transaction candidate information (source and destination, amount, fee, etc)
    /// - Returns:
    ///   - An `AnyPublisher` that returns a a signed transaction or an error
    func sign<Token>(
        candidate: NativeBitcoinChainTransactionCandidate<Token>
    ) -> AnyPublisher<SignedBitcoinChainTransaction, BitcoinTransactionSigningServiceError>
}

final class BitcoinTransactionSigningService: BitcoinTransactionSigningServiceAPI {

    func sign<Token>(
        candidate: NativeBitcoinChainTransactionCandidate<Token>
    ) -> AnyPublisher<SignedBitcoinChainTransaction, BitcoinTransactionSigningServiceError> where Token: BitcoinChainToken {
        /* TODO: Implementation Plan:
         1. Figure out how to get xPriv from the native wallet (or other means)
         1. Use the WalletCore Library
         2. Follow the steps on https://developer.trustwallet.com/wallet-core/integration-guide/wallet-core-usage
         3. Get the signed transaction hash
         */
        unimplemented()
    }
}
