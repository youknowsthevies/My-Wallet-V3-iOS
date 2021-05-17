//
//  AccountsRouter.swift
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DashboardKit
import DashboardUIKit
import DIKit
import InterestKit
import InterestUIKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class AccountsRouter: AccountsRouting {

    private let nonCustodialActionRouterAPI: NonCustodialActionRouterAPI
    private let custodyActionRouterAPI: CustodyActionRouterAPI
    private let balanceProvider: BalanceProviding
    private let disposeBag = DisposeBag()

    init(
        routing: CurrencyRouting & TabSwapping,
        balanceProvider: BalanceProviding = resolve(),
        backupRouter: DashboardUIKit.BackupRouterAPI = resolve()
    ) {
        self.nonCustodialActionRouterAPI = NonCustodialActionRouter(balanceProvider: balanceProvider, routing: routing)
        self.custodyActionRouterAPI = CustodyActionRouter(backupRouterAPI: backupRouter, tabSwapping: routing)
        self.balanceProvider = balanceProvider

        self.custodyActionRouterAPI
            .completionRelay
            .bindAndCatch(weak: self) { (_) in
                balanceProvider.refresh()
            }
            .disposed(by: disposeBag)
    }

    func routeToCustodialAccount(for currencyType: CurrencyType) {
        custodyActionRouterAPI.start(with: currencyType)
    }

    func routeToNonCustodialAccount(for currency: CryptoCurrency) {
        nonCustodialActionRouterAPI.start(with: currency)
    }

    func routeToInterestAccount(for currency: CryptoCurrency) {
        let interactor = InterestAccountDetailsScreenInteractor(
            cryptoCurrency: currency,
            assetBalanceFetching: balanceProvider[.crypto(currency)]
        )
        let presenter = InterestAccountDetailsScreenPresenter(interactor: interactor)
        let controller = InterestAccountDetailsViewController(presenter: presenter)

        let navigationRouter: NavigationRouterAPI = resolve()
        navigationRouter.present(viewController: controller, using: .modalOverTopMost)
    }
}
