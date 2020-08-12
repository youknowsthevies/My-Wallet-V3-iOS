//
//  SimpleBuyServiceProvider+Conveniences.swift
//  Blockchain
//
//  Created by Daniel Huri on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import ToolKit
import DIKit

extension ServiceProvider {
        
    convenience init(balanceProvider: BalanceProviding,
                     enabledCurrenciesService: EnabledCurrenciesService = resolve()) {
        self.init(
            cardServiceProvider: CardServiceProvider.default,
            recordingProvider: RecordingProvider.default,
            wallet: WalletManager.shared.reactiveWallet,
            settings: UserInformationServiceProvider.default.settings,
            dataRepository: BlockchainDataRepository.shared,
            tiersService: KYCServiceProvider.default.tiers,
            balanceProvider: balanceProvider,
            enabledFiatCurrencies: enabledCurrenciesService.allEnabledFiatCurrencies,
            featureFetcher: AppFeatureConfigurator.shared
        )
    }
}
