//
//  SimpleBuyServiceProvider+Conveniences.swift
//  Blockchain
//
//  Created by Daniel Huri on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import PlatformKit
import BuySellKit

extension SimpleBuyServiceProvider {
    
    static let `default`: SimpleBuyServiceProviderAPI = SimpleBuyServiceProvider()
    
    convenience init() {
        self.init(
            cardServiceProvider: CardServiceProvider.default,
            recordingProvider: RecordingProvider.default,
            wallet: ReactiveWallet(),
            authenticationService: NabuAuthenticationService.shared,
            simpleBuyClient: SimpleBuyClient(),
            cacheSuite: UserDefaults.standard,
            settings: UserInformationServiceProvider.default.settings,
            dataRepository: BlockchainDataRepository.shared,
            tiersService: KYCServiceProvider.default.tiers,
            featureFetcher: AppFeatureConfigurator.shared
        )
    }
}
