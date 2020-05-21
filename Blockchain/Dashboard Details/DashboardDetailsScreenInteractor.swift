//
//  DashboardDetailsScreenInteractor.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

final class DashboardDetailsScreenInteractor {
        
    // MARK: - Properties
    
    let priceServiceAPI: HistoricalFiatPriceServiceAPI
    let balanceFetcher: AssetBalanceFetching

    let savingsAccountService: SavingAccountServiceAPI
    
    let savingsBalanceInteractor: DashboardDetailsCustodialTypeInteractor
    let tradingBalanceInteractor: DashboardDetailsCustodialTypeInteractor

    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    private let recoveryPhraseStatus: RecoveryPhraseStatusProviding
    
    // MARK: - Setup
    
    init(currency: CryptoCurrency,
         balanceFetcher: AssetBalanceFetching,
         savingsAccountService: SavingAccountServiceAPI,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI,
         exchangeAPI: PairExchangeServiceAPI,
         wallet: Wallet = WalletManager.shared.wallet) {
        self.savingsAccountService = savingsAccountService
        self.priceServiceAPI = HistoricalFiatPriceService(
            cryptoCurrency: currency,
            exchangeAPI: exchangeAPI,
            fiatCurrencyService: fiatCurrencyService
        )
        self.recoveryPhraseStatus = RecoveryPhraseStatusProvider(wallet: wallet)
        self.fiatCurrencyService = fiatCurrencyService
        self.balanceFetcher = balanceFetcher
        
        tradingBalanceInteractor = DashboardDetailsCustodialTypeInteractor(
            balanceFetcher: balanceFetcher.trading
        )
        savingsBalanceInteractor = DashboardDetailsCustodialTypeInteractor(
            balanceFetcher: balanceFetcher.savings
        )
        
        priceServiceAPI.fetchTriggerRelay.accept(.week(.oneHour))
    }
    
    func refresh() {
        recoveryPhraseStatus.fetchTriggerRelay.accept(())
        balanceFetcher.refresh()
    }
}
