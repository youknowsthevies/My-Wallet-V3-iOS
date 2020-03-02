//
//  DashboardDetailsScreenInteractor.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

final class DashboardDetailsScreenInteractor: DashboardDetailsScreenInteracting {
    let recoveryPhraseStatus: RecoveryPhraseStatusProviding
    let recoveryPhraseVerifying: RecoveryPhraseVerifyingServiceAPI
    let currency: CryptoCurrency
    let priceServiceAPI: HistoricalFiatPriceServiceAPI
    let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    let balanceFetching: AssetBalanceFetching
    
    // MARK: - Init
    
    init(currency: CryptoCurrency,
         service: AssetBalanceFetching,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI,
         exchangeAPI: PairExchangeServiceAPI,
         wallet: Wallet = WalletManager.shared.wallet,
         historicalPricesAPI: HistoricalPricesAPI = HistoricalPriceService()) {
        self.priceServiceAPI = HistoricalFiatPriceService(
            cryptoCurrency: currency,
            exchangeAPI: exchangeAPI,
            fiatCurrencyService: fiatCurrencyService
        )
        self.recoveryPhraseStatus = RecoveryPhraseStatusProvider(wallet: wallet)
        self.recoveryPhraseVerifying = RecoveryPhraseVerifyingService(wallet: wallet)
        self.fiatCurrencyService = fiatCurrencyService
        self.currency = currency
        self.balanceFetching = service
        
        priceServiceAPI.fetchTriggerRelay.accept(.week(.oneHour))
    }
    
    func refresh() {
        recoveryPhraseStatus.fetchTriggerRelay.accept(())
        balanceFetching.refresh()
    }
}
