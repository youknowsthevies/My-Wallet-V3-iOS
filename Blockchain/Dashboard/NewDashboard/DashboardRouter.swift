//
//  DashboardRouter.swift
//  Blockchain
//
//  Created by AlexM on 11/8/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class DashboardRouter: Router {

    // MARK: Public Properties (Router)

    var navigationControllerAPI: NavigationControllerAPI?
    weak var topMostViewControllerProvider: TopMostViewControllerProviding!

    // MARK: Private Properties

    private let disposeBag = DisposeBag()
    private let routing: TabSwapping & CurrencyRouting
    private let recoveryVerifyingAPI: RecoveryPhraseVerifyingServiceAPI
    private let backupRouterAPI: BackupRouterAPI
    private let custodyActionRouterAPI: CustodyActionRouterAPI
    private let nonCustodialActionRouterAPI: NonCustodialActionRouterAPI
    private let dataProvider: DataProvider
    private let userInformationServiceProvider: UserInformationServiceProviding
    
    init(routing: CurrencyRouting & TabSwapping,
         topMostViewControllerProvider: TopMostViewControllerProviding = UIApplication.shared,
         userInformationServiceProvider: UserInformationServiceProviding = UserInformationServiceProvider.default,
         wallet: Wallet = WalletManager.shared.wallet,
         dataProvider: DataProvider = DataProvider.default,
         backupRouterAPI: BackupRouterAPI = BackupFundsCustodialRouter()) {
        self.routing = routing
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.recoveryVerifyingAPI = RecoveryPhraseVerifyingService(wallet: wallet)
        self.userInformationServiceProvider = userInformationServiceProvider
        self.dataProvider = dataProvider
        self.backupRouterAPI = backupRouterAPI
        self.custodyActionRouterAPI = CustodyActionRouter(backupRouterAPI: backupRouterAPI, tabSwapping: AppCoordinator.shared)
        self.nonCustodialActionRouterAPI = NonCustodialActionRouter(balanceProvider: dataProvider.balance, routing: routing)
        
        self.custodyActionRouterAPI
            .completionRelay
            .bindAndCatch(weak: self) { (self) in
                self.dataProvider.balance.refresh()
            }
            .disposed(by: disposeBag)
    }
    
    func showWalletActionScreen(for currencyType: CurrencyType) {
        custodyActionRouterAPI.start(with: currencyType)
    }
    
    func showDetailsScreen(for currency: CryptoCurrency) {
        // TODO: Move away from the routing layer - phase II of savings
        let savingsRatesService = SavingAccountService(
            custodialFeatureFetcher: CustodialFeatureFetcher(
                tiersService: KYCServiceProvider.default.tiers,
                featureFetching: AppFeatureConfigurator.shared
            )
        )
        let balanceFetcher = dataProvider.balance[.crypto(currency)]
        let detailsInteractor = DashboardDetailsScreenInteractor(
            currency: currency,
            balanceFetcher: balanceFetcher,
            savingsAccountService: savingsRatesService,
            fiatCurrencyService: userInformationServiceProvider.settings,
            exchangeAPI: dataProvider.exchange[currency]
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
        present(viewController: controller, using: .modalOverTopMost)
    }
    
    private func handle(action: DashboadDetailsAction) {
        switch action {
        case .buy:
            break
        case .request(let currency):
            topMostViewControllerProvider?.topMostViewController?.dismiss(animated: true, completion: nil)
            routing.toReceive(currency)
        case .send(let currency):
            topMostViewControllerProvider?.topMostViewController?.dismiss(animated: true, completion: nil)
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
