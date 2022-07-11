// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public enum BitcoinChainSigningError: Error {
    case signingError(Error)
}

public protocol BitcoinChainTransactionSigningServiceAPI {

    /// A signature verification is required for every bitcoin transaction
    /// To sign a bitcoin payment candidate, and return a signed transaction
    /// - Parameters:
    ///   - candidate: transaction candidate information (source and destination, amount, fee, etc)
    /// - Returns:
    ///   - An `AnyPublisher` that returns a a signed transaction or an error
    func sign(
        candidate: NativeBitcoinTransactionCandidate
    ) -> AnyPublisher<NativeSignedBitcoinTransaction, BitcoinChainSigningError>
}
