// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class DashboardRouter {

    private let accountsRouter: AccountsRouting
    private let disposeBag = DisposeBag()
    private let exchangeProviding: ExchangeProviding
    private let navigationRouter: NavigationRouterAPI

    init(
        navigationRouter: NavigationRouterAPI = NavigationRouter(),
        exchangeProviding: ExchangeProviding = resolve(),
        accountsRouter: AccountsRouting = resolve()
    ) {
        self.accountsRouter = accountsRouter
        self.navigationRouter = navigationRouter
        self.exchangeProviding = exchangeProviding
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
        let detailsPresenter = DashboardDetailsScreenPresenter(
            using: detailsInteractor,
            with: currency,
            router: self
        )
        detailsPresenter.action
            .emit(onNext: { [accountsRouter] action in
                switch action {
                case .routeTo(let account):
                    accountsRouter.route(to: account)
                }
            })
            .disposed(by: disposeBag)

        let controller = DashboardDetailsViewController(using: detailsPresenter)
        navigationRouter.present(viewController: controller, using: .modalOverTopMost)
    }
}
