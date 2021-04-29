// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

final class MnemonicVerificationService: MnemonicVerificationAPI {
    
    enum ServiceError: Error {
        case mnemonicVerificationError
    }
    
    private let wallet: Wallet
    private let jsScheduler = MainScheduler.instance
    
    init(wallet: Wallet = WalletManager.shared.wallet) {
        self.wallet = wallet
    }
    
    // MARK: - MnemonicVerificationAPI
    
    var isVerified: Single<Bool> {
        Single
            .just(wallet.isRecoveryPhraseVerified())
            .subscribeOn(jsScheduler)
    }
    
    func verifyMnemonicAndSync() -> Completable {
        Completable
            .create { [weak self] observer -> Disposable in
                guard let self = self else {
                    observer(.error(ToolKitError.nullReference(Self.self)))
                    return Disposables.create()
                }
                self.wallet.markRecoveryPhraseVerified(
                    completion: {
                        observer(.completed)
                    },
                    error: {
                        // There was an error syncing wallet.
                        observer(.error(ServiceError.mnemonicVerificationError))
                    }
                )
                return Disposables.create()
            }
            .subscribeOn(jsScheduler)
    }
}
