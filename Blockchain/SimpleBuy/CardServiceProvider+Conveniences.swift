//
//  CardsServiceProvider+Conveniences.swift
//  Blockchain
//
//  Created by Daniel Huri on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import ToolKit

extension CardServiceProvider {
    
    static let `default`: CardServiceProviderAPI = CardServiceProvider()
        
    convenience init() {
        self.init(
            cardClient: CardClient(),
            everyPayClient: EveryPayClient(),
            wallet: WalletManager.shared.reactiveWallet,
            authenticationService: NabuAuthenticationService.shared,
            dataRepository: BlockchainDataRepository.shared,
            featureFetcher: AppFeatureConfigurator.shared,
            analyticsRecorder: AnalyticsEventRecorder.shared,
            fiatCurrencyService: UserInformationServiceProvider.default.settings
        )
    }
}
