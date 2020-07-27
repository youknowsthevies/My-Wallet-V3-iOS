//
//  CardsServiceProvider+Conveniences.swift
//  Blockchain
//
//  Created by Daniel Huri on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import BuySellKit
import PlatformKit
import ToolKit

extension CardServiceProvider {
    
    static let `default`: CardServiceProviderAPI = CardServiceProvider()
        
    convenience init() {
        self.init(
            wallet: WalletManager.shared.reactiveWallet,
            dataRepository: BlockchainDataRepository.shared,
            featureFetcher: AppFeatureConfigurator.shared,
            analyticsRecorder: resolve(),
            fiatCurrencyService: UserInformationServiceProvider.default.settings
        )
    }
}
