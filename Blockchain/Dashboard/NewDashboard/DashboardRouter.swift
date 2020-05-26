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
import RxSwift
import RxRelay

final class DashboardRouter {
    
    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()
    private let currencyRouting: CurrencyRouting
    private let tabSwapping: TabSwapping
    private let rootViewController: TabViewController!
    private let recoveryVerifyingAPI: RecoveryPhraseVerifyingServiceAPI
    private let backupRouterAPI: BackupRouterAPI
    private let custodyActionRouterAPI: CustodyActionRouterAPI
    private let nonCustodialActionRouterAPI: NonCustodialActionRouterAPI
    private weak var topMostViewControllerProvider: TopMostViewControllerProviding?
    private let dataProvider: DataProvider
    private let userInformationServiceProvider: UserInformationServiceProviding
    
    init(rootViewController: TabViewController,
         currencyRouting: CurrencyRouting,
         topMostViewControllerProvider: TopMostViewControllerProviding = UIApplication.shared,
         userInformationServiceProvider: UserInformationServiceProviding = UserInformationServiceProvider.default,
         tabSwapping: TabSwapping,
         wallet: Wallet = WalletManager.shared.wallet,
         dataProvider: DataProvider = DataProvider.default,
         backupRouterAPI: BackupRouterAPI = BackupFundsCustodialRouter()) {
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.recoveryVerifyingAPI = RecoveryPhraseVerifyingService(wallet: wallet)
        self.userInformationServiceProvider = userInformationServiceProvider
        self.rootViewController = rootViewController
        self.dataProvider = dataProvider
        self.currencyRouting = currencyRouting
        self.tabSwapping = tabSwapping
        self.backupRouterAPI = backupRouterAPI
        self.custodyActionRouterAPI = CustodyActionRouter(backupRouterAPI: backupRouterAPI)
        self.nonCustodialActionRouterAPI = NonCustodialActionRouter(tabSwapping: tabSwapping)
        
        self.custodyActionRouterAPI
            .completionRelay
            .bind(weak: self) { (self) in
                self.dataProvider.balance.refresh()
            }
            .disposed(by: disposeBag)
    }
    
    func showDetailsScreen(for currency: CryptoCurrency) {
        // TODO: Move away from the routing layer - phase II of savings
        let savingsRatesService = SavingAccountService(authenticationService: NabuAuthenticationService.shared, featureFetching: AppFeatureConfigurator.shared)
        let balanceFetcher = dataProvider.balance[currency]
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
        let navController = NavigationController(rootViewController: controller)
        rootViewController.present(navController, animated: true, completion: nil)
    }
    
    private func handle(action: DashboadDetailsAction) {
        switch action {
        case .buy:
            break
        case .request(let currency):
            topMostViewControllerProvider?.topMostViewController?.dismiss(animated: true, completion: nil)
            currencyRouting.toReceive(currency)
        case .send(let currency):
            topMostViewControllerProvider?.topMostViewController?.dismiss(animated: true, completion: nil)
            currencyRouting.toSend(currency)
        case .nonCustodial(let currency):
            nonCustodialActionRouterAPI.start(with: currency)
        case .trading(let currency):
            custodyActionRouterAPI.start(with: currency)
        case .savings:
            break
        }
    }
}
