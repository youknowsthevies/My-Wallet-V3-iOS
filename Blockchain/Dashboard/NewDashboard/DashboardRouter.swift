//
//  DashboardRouter.swift
//  Blockchain
//
//  Created by AlexM on 11/8/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import InterestKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class DashboardRouter {

    // MARK: Private Properties

    private let disposeBag = DisposeBag()

    private let navigationRouter: NavigationRouterAPI
    private let routing: TabSwapping & CurrencyRouting
    private let recoveryVerifyingAPI: RecoveryPhraseVerifyingServiceAPI
    private let backupRouterAPI: BackupRouterAPI
    private let custodyActionRouterAPI: CustodyActionRouterAPI
    private let nonCustodialActionRouterAPI: NonCustodialActionRouterAPI
    private let userInformationServiceProvider: UserInformationServiceProviding
    private let balanceProviding: BalanceProviding
    private let exchangeProviding: ExchangeProviding
    
    init(routing: CurrencyRouting & TabSwapping,
         navigationRouter: NavigationRouterAPI = NavigationRouter(),
         userInformationServiceProvider: UserInformationServiceProviding = UserInformationServiceProvider.default,
         wallet: Wallet = WalletManager.shared.wallet,
         balanceProviding: BalanceProviding = resolve(),
         exchangeProviding: ExchangeProviding = resolve(),
         backupRouterAPI: BackupRouterAPI = BackupFundsCustodialRouter()) {
        self.navigationRouter = navigationRouter
        self.routing = routing
        self.recoveryVerifyingAPI = RecoveryPhraseVerifyingService(wallet: wallet)
        self.userInformationServiceProvider = userInformationServiceProvider
        self.balanceProviding = balanceProviding
        self.exchangeProviding = exchangeProviding
        self.backupRouterAPI = backupRouterAPI
        self.custodyActionRouterAPI = CustodyActionRouter(backupRouterAPI: backupRouterAPI, tabSwapping: AppCoordinator.shared)
        self.nonCustodialActionRouterAPI = NonCustodialActionRouter(balanceProvider: balanceProviding, routing: routing)
        
        self.custodyActionRouterAPI
            .completionRelay
            .bindAndCatch(weak: self) { (self) in
                self.balanceProviding.refresh()
            }
            .disposed(by: disposeBag)
    }
    
    func showWalletActionScreen(for currencyType: CurrencyType) {
        custodyActionRouterAPI.start(with: currencyType)
    }
    
    func showDetailsScreen(for currency: CryptoCurrency) {
        // TODO: Move away from the routing layer - phase II of savings
        let savingsRatesService: SavingAccountServiceAPI = resolve()
        
        let balanceFetcher = balanceProviding[.crypto(currency)]
        let detailsInteractor = DashboardDetailsScreenInteractor(
            currency: currency,
            balanceFetcher: balanceFetcher,
            savingsAccountService: savingsRatesService,
            fiatCurrencyService: userInformationServiceProvider.settings,
            exchangeAPI: exchangeProviding[currency]
        )
        /// FIXME: The dashboard model is not reactive to fiat currency change - at the tap
        /// time we may not have the fiat currency fetched - that can lead to a crash if the fiat is not set.
        /// alternatively (current solution) - the fiat currency defaults to USD
        let fiatCurrency = userInformationServiceProvider.settings.legacyCurrency ?? .USD
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
        case .buy:
            break
        case .request(let currency):
            navigationRouter.topMostViewControllerProvider?.topMostViewController?.dismiss(animated: true, completion: nil)
            routing.toReceive(currency)
        case .send(let currency):
            navigationRouter.topMostViewControllerProvider?.topMostViewController?.dismiss(animated: true, completion: nil)
            routing.toSend(currency)
        case .nonCustodial(let currency):
            nonCustodialActionRouterAPI.start(with: currency)
        case .trading(let currency):
            custodyActionRouterAPI.start(with: .crypto(currency))
        case .savings:
            break
        }
    }
}
