//
//  AccountsRouter.swift
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DashboardUIKit
import DIKit
import InterestUIKit
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

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
        self.nonCustodialActionRouterAPI = NonCustodialActionRouter(routing: routing)
        self.custodyActionRouterAPI = CustodyActionRouter(backupRouterAPI: backupRouter, tabSwapping: routing)
        self.balanceProvider = balanceProvider
    }

    private func routeToInterestAccount(for account: BlockchainAccount) {
        let interactor = InterestAccountDetailsScreenInteractor(account: account)
        let presenter = InterestAccountDetailsScreenPresenter(interactor: interactor)
        let controller = InterestAccountDetailsViewController(presenter: presenter)

        let navigationRouter: NavigationRouterAPI = resolve()
        navigationRouter.present(viewController: controller, using: .modalOverTopMost)
    }

    func route(to account: BlockchainAccount) {
        switch account {
        case is CryptoInterestAccount:
            routeToInterestAccount(for: account)
        case is NonCustodialAccount:
            nonCustodialActionRouterAPI.start(with: account)
        case is TradingAccount,
             is FiatAccount:
            custodyActionRouterAPI.start(with: account)
        default:
            unimplemented("Unsupported account type \(String(reflecting: account))")
        }
    }
}
