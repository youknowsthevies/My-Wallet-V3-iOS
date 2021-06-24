// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class DashboardScreenInteractor {

    // MARK: - Services

    let historicalProvider: HistoricalFiatPriceProviding
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

    init(
        historicalProvider: HistoricalFiatPriceProviding = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        reactiveWallet: ReactiveWalletAPI = resolve(),
        userPropertyInteractor: AnalyticsUserPropertyInteracting = resolve(),
        coincore: CoincoreAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        self.historicalProvider = historicalProvider
        self.reactiveWallet = reactiveWallet
        self.enabledCurrenciesService = enabledCurrenciesService
        self.userPropertyInteractor = userPropertyInteractor
        historicalBalanceInteractors = coincore.cryptoAssets.map { cryptoAsset in
            HistoricalBalanceCellInteractor(
                cryptoAsset: cryptoAsset,
                historicalFiatPriceService: historicalProvider[cryptoAsset.asset],
                fiatCurrencyService: fiatCurrencyService
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

                for interactor in self.historicalBalanceInteractors {
                    interactor.refresh()
                }

                /// Refresh dashboard interaction layer
                self.historicalProvider.refresh(window: .day(.oneHour))

                /// Record user properties once wallet is initialized
                self.userPropertyInteractor.record()
            }
            .disposed(by: disposeBag)
    }
}
