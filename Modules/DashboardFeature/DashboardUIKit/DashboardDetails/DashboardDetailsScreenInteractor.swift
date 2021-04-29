// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
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
    private let savingsAccountService: SavingsOverviewAPI
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    private let recoveryPhraseStatus: RecoveryPhraseStatusProviding
    
    // MARK: - Setup
    
    init(currency: CryptoCurrency,
         balanceFetcher: AssetBalanceFetching,
         savingsAccountService: SavingsOverviewAPI = resolve(),
         fiatCurrencyService: FiatCurrencySettingsServiceAPI = resolve(),
         exchangeAPI: PairExchangeServiceAPI) {
        self.blockchainAccountFetcher = BlockchainAccountFetchingFactory.make(for: .crypto(currency))
        self.currency = currency
        self.savingsAccountService = savingsAccountService
        self.priceServiceAPI = HistoricalFiatPriceService(
            cryptoCurrency: currency,
            exchangeAPI: exchangeAPI,
            fiatCurrencyService: fiatCurrencyService
        )
        self.recoveryPhraseStatus = resolve()
        self.fiatCurrencyService = fiatCurrencyService
        self.balanceFetcher = balanceFetcher

        priceServiceAPI.fetchTriggerRelay.accept(.week(.oneHour))
    }
    
    func refresh() {
        recoveryPhraseStatus.fetchTriggerRelay.accept(())
        balanceFetcher.refresh()
    }
}
