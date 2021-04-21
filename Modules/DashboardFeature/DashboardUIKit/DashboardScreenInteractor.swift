//
//  DashboardScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 22/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class DashboardScreenInteractor {
    
    // MARK: - Services
    
    let balanceProvider: BalanceProviding
    let historicalProvider: HistoricalFiatPriceProviding
    let balanceChangeProvider: BalanceChangeProviding
    let reactiveWallet: ReactiveWalletAPI
    let userPropertyInteractor: AnalyticsUserPropertyInteracting
    
    let historicalBalanceInteractors: [HistoricalBalanceCellInteractor]
    let fiatBalancesInteractor: DashboardFiatBalancesInteractor
    let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    
    var enabledCryptoCurrencies: [CryptoCurrency] {
        enabledCurrenciesService.allEnabledCryptoCurrencies
    }
    
    // MARK: - Private Accessors
    
    private let disposeBag = DisposeBag()
    
    init(balanceProvider: BalanceProviding = resolve(),
         historicalProvider: HistoricalFiatPriceProviding = resolve(),
         balanceChangeProvider: BalanceChangeProviding = resolve(),
         enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
         reactiveWallet: ReactiveWalletAPI = resolve(),
         userPropertyInteractor: AnalyticsUserPropertyInteracting = resolve()) {
        self.historicalProvider = historicalProvider
        self.balanceProvider = balanceProvider
        self.balanceChangeProvider = balanceChangeProvider
        self.reactiveWallet = reactiveWallet
        self.enabledCurrenciesService = enabledCurrenciesService
        self.userPropertyInteractor = userPropertyInteractor
        historicalBalanceInteractors = enabledCurrenciesService.allEnabledCryptoCurrencies.map {
            HistoricalBalanceCellInteractor(
                cryptoCurrency: $0,
                historicalFiatPriceService: historicalProvider[$0],
                assetBalanceFetcher: balanceProvider[$0.currency]
            )
        }
        
        fiatBalancesInteractor = DashboardFiatBalancesInteractor(fiatBalancesInteractor: resolve())
        
        NotificationCenter.when(.walletInitialized) { [weak self] _ in
            self?.refresh()
        }
    }
    
    func refresh() {
        reactiveWallet.waitUntilInitialized
            .bind { [weak self] _ in
                guard let self = self else { return }
                
                /// Refresh dashboard interaction layer
                self.historicalProvider.refresh(window: .day(.oneHour))
                self.balanceProvider.refresh()
                
                /// Record user properties once wallet is initialized
                self.userPropertyInteractor.record()
            }
            .disposed(by: disposeBag)
    }
}
