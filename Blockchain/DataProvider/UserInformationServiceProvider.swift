//
//  UserInformationServiceProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 24/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit

final class UserInformationServiceProvider: UserInformationServiceProviding {
    
    /// The default container
    @Inject static var `default`: UserInformationServiceProviding
    
    /// Persistent service that has access to the general wallet settings
    let settings: CompleteSettingsServiceAPI
    
    /// Computes and returns an email verification service API
    let emailVerification: EmailVerificationServiceAPI
    
    let general: GeneralInformationServiceAPI
    let walletSynchronizer: WalletNabuSynchronizerServiceAPI
    
    init(settingsService: CompleteSettingsServiceAPI = resolve(),
         emailVerification: EmailVerificationServiceAPI = resolve(),
         generalInformationService: GeneralInformationServiceAPI = resolve(),
         walletSynchronizer: WalletNabuSynchronizerServiceAPI = resolve()) {
        self.settings = settingsService
        self.emailVerification = emailVerification
        self.general = generalInformationService
        self.walletSynchronizer = walletSynchronizer
    }
}
