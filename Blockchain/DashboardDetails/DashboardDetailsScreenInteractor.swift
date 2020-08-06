//
//  DashboardDetailsScreenInteractor.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import InterestKit
import PlatformKit
import PlatformUIKit
import RxSwift

final class DashboardDetailsScreenInteractor {
        
    // MARK: - Public Properties
    
    var nonCustodialActivitySupported: Observable<Bool> {
        walletBalanceInteractor.exists
    }
    
    var custodialTradingFunded: Observable<Bool> {
        tradingBalanceInteractor.exists
    }
    
    var custodialSavingsFunded: Observable<Bool> {
        savingsBalanceInteractor.exists
    }
    
    var rate: Single<Double> {
        savingsAccountService
            .rate(for: currency)
    }
    
    let priceServiceAPI: HistoricalFiatPriceServiceAPI
    let balanceFetcher: AssetBalanceFetching
    
    // MARK: - Private Properties
    
    private let walletBalanceInteractor: DashboardDetailsNonCustodialTypeInteractor
    private let savingsBalanceInteractor: DashboardDetailsCustodialTypeInteractor
    private let tradingBalanceInteractor: DashboardDetailsCustodialTypeInteractor

    private let currency: CryptoCurrency
    private let savingsAccountService: SavingAccountServiceAPI
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    private let recoveryPhraseStatus: RecoveryPhraseStatusProviding
    
    // MARK: - Setup
    
    init(currency: CryptoCurrency,
         balanceFetcher: AssetBalanceFetching,
         savingsAccountService: SavingAccountServiceAPI,
         fiatCurrencyService: FiatCurrencySettingsServiceAPI,
         exchangeAPI: PairExchangeServiceAPI,
         wallet: Wallet = WalletManager.shared.wallet) {
        self.currency = currency
        self.savingsAccountService = savingsAccountService
        self.priceServiceAPI = HistoricalFiatPriceService(
            cryptoCurrency: currency,
            exchangeAPI: exchangeAPI,
            fiatCurrencyService: fiatCurrencyService
        )
        self.recoveryPhraseStatus = RecoveryPhraseStatusProvider(wallet: wallet)
        self.fiatCurrencyService = fiatCurrencyService
        self.balanceFetcher = balanceFetcher

        walletBalanceInteractor = DashboardDetailsNonCustodialTypeInteractor(
            currency: currency
        )
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
