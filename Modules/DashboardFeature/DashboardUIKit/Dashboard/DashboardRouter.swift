// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class DashboardRouter {

    private let disposeBag = DisposeBag()

    private let accountsRouter: AccountsRouting
    private let navigationRouter: NavigationRouterAPI
    private let exchangeProviding: ExchangeProviding
    private let settingsService: FiatCurrencySettingsServiceAPI

    init(
        navigationRouter: NavigationRouterAPI = NavigationRouter(),
        exchangeProviding: ExchangeProviding = resolve(),
        settingsService: FiatCurrencySettingsServiceAPI = resolve(),
        accountsRouter: AccountsRouting = resolve()
    ) {
        self.accountsRouter = accountsRouter
        self.navigationRouter = navigationRouter
        self.exchangeProviding = exchangeProviding
        self.settingsService = settingsService
    }

    func showWalletActionScreen(for account: BlockchainAccount) {
        accountsRouter.route(to: account)
    }

    func showDetailsScreen(for currency: CryptoCurrency) {
        // TODO: Move away from the routing layer - phase II of saving
        let detailsInteractor = DashboardDetailsScreenInteractor(
            currency: currency,
            exchangeAPI: exchangeProviding[currency]
        )
        /// FIXME: The dashboard model is not reactive to fiat currency change - at the tap
        /// time we may not have the fiat currency fetched - that can lead to a crash if the fiat is not set.
        /// alternatively (current solution) - the fiat currency defaults to USD
        let fiatCurrency = settingsService.legacyCurrency ?? .USD
        let detailsPresenter = DashboardDetailsScreenPresenter(
            using: detailsInteractor,
            with: currency,
            fiatCurrency: fiatCurrency,
            router: self
        )

        detailsPresenter.action
            .emit(onNext: { [weak self] action in
                guard let self = self else { return }
                self.handle(action: action)
            })
            .disposed(by: disposeBag)

        let controller = DashboardDetailsViewController(using: detailsPresenter)
        navigationRouter.present(viewController: controller, using: .modalOverTopMost)
    }

    private func handle(action: DashboadDetailsAction) {
        switch action {
        case .routeTo(let account):
            accountsRouter.route(to: account)
        }
    }
}
