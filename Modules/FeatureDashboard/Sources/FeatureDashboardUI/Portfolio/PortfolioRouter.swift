// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class PortfolioRouter {

    private let accountsRouter: AccountsRouting
    private let disposeBag = DisposeBag()

    init(
        navigationRouter: NavigationRouterAPI = NavigationRouter(),
        exchangeProviding: ExchangeProviding = resolve(),
        accountsRouter: AccountsRouting = resolve()
    ) {
        self.accountsRouter = accountsRouter
    }

    func showWalletActionScreen(for account: BlockchainAccount) {
        accountsRouter.route(to: account)
    }
}
