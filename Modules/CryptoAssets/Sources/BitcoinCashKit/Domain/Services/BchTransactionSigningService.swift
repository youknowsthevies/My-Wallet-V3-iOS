// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Combine

final class BchTransactionSigningService: BitcoinChainTransactionSigningServiceAPI {

    private let signingInputService: BchSigningInputServiceAPI
    private let signingService: BchSigningServiceAPI

    init(signingInputService: BchSigningInputServiceAPI, signingService: BchSigningServiceAPI) {
        self.signingInputService = signingInputService
        self.signingService = signingService
    }

    func sign(
        candidate: NativeBitcoinTransactionCandidate
    ) -> AnyPublisher<NativeSignedBitcoinTransaction, BitcoinChainSigningError> {
        signingInputService.build(candidate: candidate)
            .eraseError()
            .flatMap { [signingService] signingInput -> AnyPublisher<BchSigningOutput, Error> in
                signingService
                    .sign(input: signingInput)
                    .publisher
                    .eraseError()
            }
            .map { (signed: BchSigningOutput) -> NativeSignedBitcoinTransaction in
                NativeSignedBitcoinTransaction(
                    msgSize: signed.data.count,
                    txHash: signed.transactionHash,
                    encodedMsg: signed.data.hex,
                    replayProtectionLockSecret: signed.replayProtectionLockSecret
                )
            }
            .mapError(BitcoinChainSigningError.signingError)
            .eraseToAnyPublisher()
    }
}
