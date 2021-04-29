// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

final class RecoveryPhraseVerifyingService: RecoveryPhraseVerifyingServiceAPI {
    
    var phraseComponents: [String] = []
    var selection: [String] = []
    
    private let verificationService: MnemonicVerificationService
    
    init(wallet: Wallet = WalletManager.shared.wallet) {
        self.verificationService = MnemonicVerificationService(wallet: wallet)
    }
    
    func markBackupVerified() -> Completable {
        verificationService.verifyMnemonicAndSync()
    }
}

