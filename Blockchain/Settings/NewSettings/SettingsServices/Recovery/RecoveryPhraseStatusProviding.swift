//
//  RecoveryPhraseStatusProviding.swift
//  Blockchain
//
//  Created by AlexM on 12/18/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxRelay
import RxSwift

final class RecoveryPhraseStatusProvider: RecoveryPhraseStatusProviding {
    
    let fetchTriggerRelay = PublishRelay<Void>()
    
    var isRecoveryPhraseVerifiedObservable: Observable<Bool> {
        fetchTriggerRelay
            .flatMap(weak: self) { (self, _) -> Observable<Bool> in
                .just(self.wallet.isRecoveryPhraseVerified())
            }
    }
    
    var isRecoveryPhraseVerified: Bool {
        wallet.isRecoveryPhraseVerified()
    }
    
    private let isVerified = PublishRelay<Bool>()
    private let wallet: Wallet
    
    init(wallet: Wallet = WalletManager.shared.wallet) {
        self.wallet = wallet
        isVerified.accept(wallet.isRecoveryPhraseVerified())
    }
}
