//
//  DashboardDetailsScreenInteractor.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import InterestKit
import PlatformKit
import PlatformUIKit
import RxSwift

final class DashboardDetailsScreenInteractor {
        
    // MARK: - Public Properties
    
    var nonCustodialActivitySupported: Observable<Bool> {
        Observable.just(currency.hasNonCustodialActivitySupport)
    }
    
    var custodialSavingsFunded: Observable<Bool> {
        blockchainAccountFetcher
            .account(accountType: .custodial(.savings))
            .asObservable()
            .take(1)
            .flatMap { $0.isFunded }
            .catchErrorJustReturn(false)
    }
    
    var rate: Single<Double> {
        savingsAccountService
            .rate(for: currency)
    }
    
    let priceServiceAPI: HistoricalFiatPriceServiceAPI
    let balanceFetcher: AssetBalanceFetching
    
    // MARK: - Private Properties
    
    private let blockchainAccountFetcher: BlockchainAccountFetching

    private let currency: CryptoCurrency
    private let savingsAccountService: SavingAccountServiceAPI
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    private let recoveryPhraseStatus: RecoveryPhraseStatusProviding
    
    // MARK: - Setup
    
    init(currency: CryptoCurrency,
         balanceFetcher: AssetBalanceFetching,
         savingsAccountService: SavingAccountServiceAPI = resolve(),
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = resolve(),
         exchangeAPI: PairExchangeServiceAPI,
         wallet: Wallet = WalletManager.shared.wallet) {
        self.blockchainAccountFetcher = BlockchainAccountFetchingFactory.make(for: .crypto(currency))
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

        priceServiceAPI.fetchTriggerRelay.accept(.week(.oneHour))
    }
    
    func refresh() {
        recoveryPhraseStatus.fetchTriggerRelay.accept(())
        balanceFetcher.refresh()
    }
}
