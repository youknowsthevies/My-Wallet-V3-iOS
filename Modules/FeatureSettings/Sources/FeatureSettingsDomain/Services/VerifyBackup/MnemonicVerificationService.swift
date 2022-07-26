// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit

public protocol WalletRecoveryVerifing {
    func isRecoveryPhraseVerified() -> Bool
    func markRecoveryPhraseVerified(completion: (() -> Void)?, error: (() -> Void)?)
}

enum MnemonicVerificationServiceError: Error {
    case mnemonicVerificationError
}

final class MnemonicVerificationService: MnemonicVerificationAPI {

    let walletRecoveryVerifier: WalletRecoveryVerifing
    private let jsScheduler = DispatchQueue.main

    init(walletRecoveryVerifier: WalletRecoveryVerifing) {
        self.walletRecoveryVerifier = walletRecoveryVerifier
    }

    // MARK: - MnemonicVerificationAPI

    var isVerified: AnyPublisher<Bool, Never> {
        Just(walletRecoveryVerifier.isRecoveryPhraseVerified())
            .subscribe(on: jsScheduler)
            .eraseToAnyPublisher()
    }

    func verifyMnemonicAndSync() -> AnyPublisher<EmptyValue, MnemonicVerificationServiceError> {
        Deferred { [walletRecoveryVerifier] in
            Future<EmptyValue, MnemonicVerificationServiceError> { promise in
                walletRecoveryVerifier.markRecoveryPhraseVerified(
                    completion: {
                        promise(.success(.noValue))
                    },
                    error: {
                        promise(.failure(.mnemonicVerificationError))
                    }
                )
            }
        }
        .subscribe(on: jsScheduler)
        .eraseToAnyPublisher()
    }
}
