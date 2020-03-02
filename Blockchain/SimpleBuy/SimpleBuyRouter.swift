//
//  SimpleBuyRouter.swift
//  Blockchain
//
//  Created by Daniel Huri on 21/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import PlatformUIKit

protocol SimpleBuyRouterAPI: class {
    func start()
    func next(to state: SimpleBuyStateService.State)
    func previous(from state: SimpleBuyStateService.State)
    func showCryptoSelectionScreen()
}

/// This object is used as a router for Simple-Buy flow
final class SimpleBuyRouter: SimpleBuyRouterAPI, Router {
    
    // MARK: - `Router` Properties
    
    weak var topMostViewControllerProvider: TopMostViewControllerProviding!
    weak var navigationControllerAPI: NavigationControllerAPI?

    // MARK: - Private Properties
    
    private let stateService: SimpleBuyStateServiceAPI
    private let kycRouter: KYCRouterAPI
    private let kycServiceProvider: KYCServiceProviderAPI
    private let serviceProvider: SimpleBuyServiceProviderAPI
    private let cryptoSelectionService: SelectionServiceAPI
    
    /// A kyc subscription dispose bag
    private var kycDisposeBag = DisposeBag()
        
    /// A general dispose bag
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(serviceProvider: SimpleBuyServiceProviderAPI = SimpleBuyServiceProvider.default,
         stateService: SimpleBuyStateServiceAPI = SimpleBuyStateService(),
         kycServiceProvider: KYCServiceProviderAPI = KYCServiceProvider.default,
         topMostViewControllerProvider: TopMostViewControllerProviding = UIApplication.shared,
         kycRouter: KYCRouterAPI = KYCCoordinator.shared) {
        self.serviceProvider = serviceProvider
        self.stateService = stateService
        self.kycServiceProvider = kycServiceProvider
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.kycRouter = kycRouter
        
        let cryptoSelectionService = SimpleBuyCryptoCurrencySelectionService(
            service: serviceProvider.supportedPairsInteractor,
            defaultSelectedData: CryptoCurrency.bitcoin
        )
        self.cryptoSelectionService = cryptoSelectionService
    }
    
    func showCryptoSelectionScreen() {
        let interactor = SelectionScreenInteractor(service: cryptoSelectionService)
        let presenter = SelectionScreenPresenter(
            title: LocalizationConstants.SimpleBuy.CryptoSelectionScreen.title,
            interactor: interactor
        )
        let viewController = SelectionScreenViewController(presenter: presenter)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationControllerAPI?.present(navigationController, animated: true, completion: nil)
    }
        
    /// Should be called once
    func start() {
        stateService.action
            .bind(weak: self) { (self, action) in
                switch action {
                case .previous(let state):
                    self.previous(from: state)
                case .next(let state):
                    self.next(to: state)
                case .dismiss:
                    self.navigationControllerAPI?.dismiss(animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
        stateService.nextRelay.accept(())
    }
    
    func next(to state: SimpleBuyStateService.State) {
        switch state {
        case .intro:
            showIntroScreen()
        case .buy:
            showBuyCryptoScreen()
        case .checkout(let data):
            showCheckoutScreen(with: data)
        case .transferDetails(let data):
            showTransferDetailScreen(with: data, presentationType: .checkoutSummary)
        case .transferCancellation(let data):
            showTransferCancellation(with: data)
        case .pendingOrderDetails(let data):
            showTransferDetailScreen(with: data, presentationType: .pendingOrder)
        case .kyc:
            showKYC()
        case .pendingKycApproval:
            showPendingKycApprovalScreen()
        case .inactive:
            navigationControllerAPI?.dismiss(animated: true, completion: nil)
        }
    }
    
    func previous(from state: SimpleBuyStateService.State) {
        switch state {
        // KYC is an independent flow which dismisses itself.
        // Therefore, do nothing.
        case .kyc:
            break
        default:
            dismiss()
        }
    }
    
    /// Shows the checkout details screen
    private func showTransferDetailScreen(with data: SimpleBuyCheckoutData,
                                          presentationType: SimpleBuyTransferDetailScreenPresenter.PresentationType) {
        let interactor = SimpleBuyTransferDetailScreenInteractor(
            checkoutData: data,
            cancellationService: serviceProvider.orderCancellation
        )
        
        let webViewRouter = WebViewRouter(
            topMostViewControllerProvider: topMostViewControllerProvider,
            webViewServiceAPI: UIApplication.shared
        )
        
        let presenter = SimpleBuyTransferDetailScreenPresenter(
            presentationType: presentationType,
            webViewRouter: webViewRouter,
            interactor: interactor,
            stateService: stateService
        )
        let viewController = SimpleBuyTransferDetailScreenViewController(using: presenter)
        present(viewController: viewController)
    }
    
    /// Shows the cancellation modal
    private func showTransferCancellation(with data: SimpleBuyCheckoutData) {
        let interactor = SimpleBuyTransferCancellationInteractor(
            checkoutData: data,
            cancellationService: serviceProvider.orderCancellation
        )
        
        let presenter = SimpleBuyTransferCancellationScreenPresenter(
            stateService: stateService,
            currency: data.cryptoCurrency,
            interactor: interactor
        )
        let viewController = SimpleBuyTransferCancellationViewController(presenter: presenter)
        viewController.transitioningDelegate = sheetPresenter
        viewController.modalPresentationStyle = .custom
        topMostViewControllerProvider.topMostViewController?.present(viewController, animated: true, completion: nil)
    }
    
    /// Shows the checkout screen
    private func showCheckoutScreen(with data: SimpleBuyCheckoutData) {
        let interactor = CheckoutScreenInteractor(
            paymentAccountService: serviceProvider.paymentAccount,
            orderQuoteService: serviceProvider.orderQuote,
            orderCreationService: serviceProvider.orderCreation,
            checkoutData: data
        )
        let presenter = CheckoutScreenPresenter(
            stateService: stateService,
            interactor: interactor
        )
        let viewController = CheckoutScreenViewController(using: presenter)
        present(viewController: viewController)
    }

    /// Show the pending kyc screen
    private func showPendingKycApprovalScreen() {
        let interactor = SimpleBuyKYCPendingInteractor(
            kycTiersService: kycServiceProvider.tiersPollingService,
            eligibilityService: serviceProvider.eligibility
        )
        let presenter = SimpleBuyKYCPendingPresenter(
            stateService: stateService,
            interactor: interactor
        )
        let viewController = SimpleBuyKYCPendingViewController(presenter: presenter)
        present(viewController: viewController, using: .navigationFromCurrent)
    }
    
    private func showKYC() {
        guard let kycRootViewController = navigationControllerAPI as? UIViewController else {
            return
        }
        
        kycDisposeBag = DisposeBag()
        let stopped = kycRouter.kycStopped
            .take(1)
            .observeOn(MainScheduler.instance)
            .share()
        
        stopped
            .filter { $0 == .tier2 }
            .mapToVoid()
            .bind(to: stateService.nextRelay)
            .disposed(by: kycDisposeBag)
        
        stopped
            .filter { $0 != .tier2 }
            .mapToVoid()
            .bind(to: stateService.previousRelay)
            .disposed(by: kycDisposeBag)
        
        kycRouter.start(from: kycRootViewController, tier: .tier2, parentFlow: .simpleBuy)
    }
    
    /// Shows buy-crypto screen using a specified presentation type
    private func showBuyCryptoScreen() {
        let interactor = BuyCryptoScreenInteractor(
            kycTiersService: kycServiceProvider.tiers,
            fiatCurrencyService: serviceProvider.settings,
            pairsService: serviceProvider.supportedPairsInteractor,
            cryptoCurrencySelectionService: cryptoSelectionService,
            suggestedAmountsService: serviceProvider.suggestedAmounts
        )
        /// TODO: Remove router injection - use `stateService` as replacement
        let presenter = BuyCryptoScreenPresenter(
            router: self,
            stateService: stateService,
            interactor: interactor
        )
        let viewController = BuyCryptoScreenViewController(presenter: presenter)
        
        present(viewController: viewController)
    }

    /// Shows intro screen using a specified presentation type
    private func showIntroScreen() {
        let presenter = BuyIntroScreenPresenter(stateService: stateService)
        let viewController = BuyIntroScreenViewController(presenter: presenter)
        present(viewController: viewController)
    }
    
    private lazy var sheetPresenter: BottomSheetPresenting = {
        return BottomSheetPresenting()
    }()
}
