//
//  MnemonicVerificationService.swift
//  Blockchain
//
//  Created by AlexM on 1/21/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

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
                guard let self = self else { return Disposables.create() }
                self.wallet.markRecoveryPhraseVerified(completion: {
                    observer(.completed)
                }, error: {
                    observer(.error(ServiceError.mnemonicVerificationError))
                })
                return Disposables.create()
            }
            .subscribeOn(jsScheduler)
    }
}
