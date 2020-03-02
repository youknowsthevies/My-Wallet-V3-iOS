//
//  BackupFundsServiceProvider.swift
//  Blockchain
//
//  Created by AlexM on 2/4/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

protocol BackupFundsServiceProviderAPI: class {
    var mnemonicAccessAPI: MnemonicAccessAPI { get }
    var recoveryPhraseVerifyingAPI: RecoveryPhraseVerifyingServiceAPI { get set }
    var mnemonicComponentsProviding: MnemonicComponentsProviding { get }
}

final class BackupFundsServiceProvider: BackupFundsServiceProviderAPI {
    
    static let `default`: BackupFundsServiceProvider = BackupFundsServiceProvider()
    
    let mnemonicAccessAPI: MnemonicAccessAPI
    let mnemonicComponentsProviding: MnemonicComponentsProviding
    var recoveryPhraseVerifyingAPI: RecoveryPhraseVerifyingServiceAPI
    
    init(mnemonicAccessAPI: MnemonicAccessAPI = WalletManager.shared.wallet,
         recoveryPhraseVerifyingAPI: RecoveryPhraseVerifyingServiceAPI = RecoveryPhraseVerifyingService()) {
        self.mnemonicAccessAPI = mnemonicAccessAPI
        self.mnemonicComponentsProviding = MnemonicComponentsProvider(mnemonicAccessAPI: mnemonicAccessAPI)
        self.recoveryPhraseVerifyingAPI = recoveryPhraseVerifyingAPI
    }
}
