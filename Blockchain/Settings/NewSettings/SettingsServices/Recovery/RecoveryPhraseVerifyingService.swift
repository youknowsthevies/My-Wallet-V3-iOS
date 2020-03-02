//
//  RecoveryPhraseVerifyingService.swift
//  Blockchain
//
//  Created by AlexM on 2/3/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

final class RecoveryPhraseVerifyingService: RecoveryPhraseVerifyingServiceAPI {
    
    var phraseComponents: [String] = []
    var selection: [String] = []
    
    private let verificationService: MnemonicVerificationService
    
    init(wallet: Wallet = WalletManager.shared.wallet) {
        self.verificationService = MnemonicVerificationService(wallet: wallet)
    }
    
    func markBackupVerified() -> Completable {
        return verificationService.verifyMnemonicAndSync()
    }
}

