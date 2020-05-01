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
import ToolKit

protocol SimpleBuyRouterAPI: class {
    func start()
    func next(to state: SimpleBuyStateService.State)
    func previous(from state: SimpleBuyStateService.State)
    func showCryptoSelectionScreen()
}

/// This object is used as a router for Simple-Buy flow
final class SimpleBuyRouter: SimpleBuyRouterAPI, Router {
    
    // MARK: - Types
    
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    
    // MARK: - `Router` Properties
    
    weak var topMostViewControllerProvider: TopMostViewControllerProviding!
    weak var navigationControllerAPI: NavigationControllerAPI?

    // MARK: - Private Properties
    
    private let analyticsRecording: AnalyticsEventRecording
    private let stateService: SimpleBuyStateServiceAPI
    private let kycRouter: KYCRouterAPI
    private let kycServiceProvider: KYCServiceProviderAPI
    private let serviceProvider: SimpleBuyServiceProviderAPI
    private let cardServiceProvider: CardServiceProviderAPI
    private let cryptoSelectionService: SelectionServiceAPI
    private let exchangeProvider: ExchangeProviding
    
    private var addCardStateService: AddCardStateService!
    private var addCardRouter: AddCardRouter!
    
    /// A kyc subscription dispose bag
    private var kycDisposeBag = DisposeBag()
        
    /// A general dispose bag
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(serviceProvider: SimpleBuyServiceProviderAPI = SimpleBuyServiceProvider.default,
         cardServiceProvider: CardServiceProviderAPI = CardServiceProvider.default,
         stateService: SimpleBuyStateServiceAPI = SimpleBuyStateService(),
         kycServiceProvider: KYCServiceProviderAPI = KYCServiceProvider.default,
         analyticsRecording: AnalyticsEventRecording = AnalyticsEventRecorder.shared,
         topMostViewControllerProvider: TopMostViewControllerProviding = UIApplication.shared,
         kycRouter: KYCRouterAPI = KYCCoordinator.shared,
         exchangeProvider: ExchangeProviding = DataProvider.default.exchange) {
        self.analyticsRecording = analyticsRecording
        self.serviceProvider = serviceProvider
        self.cardServiceProvider = cardServiceProvider
        self.stateService = stateService
        self.kycServiceProvider = kycServiceProvider
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.exchangeProvider = exchangeProvider
        self.kycRouter = kycRouter
                
        let cryptoSelectionService = SimpleBuyCryptoCurrencySelectionService(
            service: serviceProvider.supportedPairsInteractor,
            defaultSelectedData: CryptoCurrency.bitcoin
        )
        
        self.cryptoSelectionService = cryptoSelectionService
    }
    
    func showCryptoSelectionScreen() {
        typealias LocalizedString = LocalizationConstants.SimpleBuy.CryptoSelectionScreen
        let interactor = SelectionScreenInteractor(service: cryptoSelectionService)
        let presenter = SelectionScreenPresenter(
            title: LocalizedString.title,
            searchBarPlaceholder: LocalizedString.searchBarPlaceholder,
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
        case .changeFiat:
            let settingsService = UserInformationServiceProvider.default.settings
            settingsService
                .fiatCurrency
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] currency in
                    self?.showFiatCurrencyChangeScreen(selectedCurrency: currency)
                })
                .disposed(by: disposeBag)
        case .selectFiat:
            let settingsService = UserInformationServiceProvider.default.settings
            settingsService
                .fiatCurrency
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] currency in
                    self?.showFiatCurrencySelectionScreen(selectedCurrency: currency)
                })
                .disposed(by: disposeBag)
        case .unsupportedFiat(let currency):
            showInelligibleCurrency(with: currency)
        case .buy:
            showBuyCryptoScreen()
        case .checkout(let data):
            showCheckoutScreen(with: data)
        case .authorizeCard(let data):
            showCardAuthorization(with: data)
        case .pendingOrderCompleted(amount: let amount, orderId: let orderId):
            showPendingOrderCompletionScreen(for: orderId, cryptoValue: amount)
        case .paymentMethods:
            showPaymentMethodsScreen()
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
        case .addCard(let data):
            startCardAdditionFlow(with: data)
        case .inactive:
            navigationControllerAPI?.dismiss(animated: true, completion: nil)
        }
    }
    
    func previous(from state: SimpleBuyStateService.State) {
        switch state {
        // Some independent flows which dismiss themselves.
        // Therefore, do nothing.
        case .kyc, .selectFiat, .changeFiat, .unsupportedFiat, .addCard:
            break
        case .paymentMethods:
            topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: nil)
        default:
            dismiss()
        }
    }
    
    private func startCardAdditionFlow(with checkoutData: SimpleBuyCheckoutData) {
        let addCardStateService = stateService.addCardStateService(with: checkoutData)
        addCardRouter = AddCardRouter(
            stateService: addCardStateService,
            routingType: .modal
        )
        addCardRouter.setup()
        addCardStateService.start()
    }
    
    private func showFiatCurrencyChangeScreen(selectedCurrency: FiatCurrency) {
        let selectionService = FiatCurrencySelectionService(
            defaultSelectedData: selectedCurrency,
            availableCurrencies: SimpleBuyLocallySupportedCurrencies.fiatCurrencies
        )
        let interactor = SelectionScreenInteractor(service: selectionService)
        let presenter = SelectionScreenPresenter(
            title: LocalizationConstants.localCurrency,
            description: LocalizationConstants.localCurrencyDescription,
            searchBarPlaceholder: LocalizationConstants.Settings.SelectCurrency.searchBarPlaceholder,
            interactor: interactor
        )
        let viewController = SelectionScreenViewController(presenter: presenter)
        analyticsRecording.record(event: AnalyticsEvent.sbCurrencySelectScreen)
        
        present(viewController: viewController)
        
        interactor.dismiss
            .bind { [weak self] in
                self?.stateService.previousRelay.accept(())
            }
            .disposed(by: disposeBag)        
        
        interactor.selectedIdOnDismissal
            .map { FiatCurrency(code: $0)! }
            .flatMap(weak: self, { (self, currency) -> Single<(FiatCurrency, Bool)> in
                // TICKET: IOS-3144
                UserInformationServiceProvider.default.settings
                .update(
                    currency: currency,
                    context: .settings
                )
                .andThen(Single.zip(
                    Single.just(currency),
                    self.serviceProvider.flowAvailability.isFiatCurrencySupportedLocal(currency: currency)
                ))
            })
            .observeOn(MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] value in
                    guard let self = self else { return }
                    /// TODO: Remove this and `fiatCurrencySelected` once `ReceiveBTC` and
                    /// `SendBTC` are replaced with Swift implementations.
                    NotificationCenter.default.post(name: .fiatCurrencySelected, object: nil)
                    self.analyticsRecording.record(event: AnalyticsEvent.sbCurrencySelected(currencyCode: value.0.code))
                    
                    self.stateService.previousRelay.accept(())
                })
            .disposed(by: disposeBag)
    }
    
    private func showFiatCurrencySelectionScreen(selectedCurrency: FiatCurrency) {
        let selectionService = FiatCurrencySelectionService(defaultSelectedData: selectedCurrency)
        let interactor = SelectionScreenInteractor(service: selectionService)
        let presenter = SelectionScreenPresenter(
            title: LocalizationConstants.localCurrency,
            description: LocalizationConstants.localCurrencyDescription,
            shouldPreselect: false,
            searchBarPlaceholder: LocalizationConstants.Settings.SelectCurrency.searchBarPlaceholder,
            interactor: interactor
        )
        let viewController = SelectionScreenViewController(presenter: presenter)
        if #available(iOS 13.0, *) {
            viewController.isModalInPresentation = true
        }
        
        if navigationControllerAPI == nil {
            present(viewController: viewController)
        } else {
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationControllerAPI?.present(navigationController, animated: true, completion: nil)
        }
        
        interactor.dismiss
            .bind { [weak self] in
                self?.stateService.previousRelay.accept(())
            }
            .disposed(by: disposeBag)
        
        interactor.selectedIdOnDismissal
            .map { FiatCurrency(code: $0)! }
            .flatMap(weak: self, { (self, currency) -> Single<(FiatCurrency, Bool)> in
                // TICKET: IOS-3144
                UserInformationServiceProvider.default.settings
                .update(
                    currency: currency,
                    context: .settings
                )
                .andThen(Single.zip(
                    Single.just(currency),
                    self.serviceProvider.flowAvailability.isFiatCurrencySupportedLocal(currency: currency)
                ))
            })
            .observeOn(MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] value in
                    guard let self = self else { return }
                    /// TODO: Remove this and `fiatCurrencySelected` once `ReceiveBTC` and
                    /// `SendBTC` are replaced with Swift implementations.
                    NotificationCenter.default.post(name: .fiatCurrencySelected, object: nil)
                    self.analyticsRecording.record(event: AnalyticsEvent.sbCurrencySelected(currencyCode: value.0.code))
                    
                    let isFiatCurrencySupported = value.1
                    let currency = value.0
                    
                    self.dismiss {
                        self.stateService.previousRelay.accept(())
                        if !isFiatCurrencySupported {
                            self.stateService.ineligible(with: currency)
                        } else {
                            self.stateService.currencySelected()
                        }
                    }
                })
            .disposed(by: disposeBag)
    }
    
    private func showPaymentMethodsScreen() {
        let interactor = PaymentMethodsScreenInteractor(
            service: serviceProvider.paymentMethodTypes
        )
        let presenter = PaymentMethodsScreenPresenter(
            interactor: interactor,
            stateService: stateService
        )
        let viewController = PaymentMethodsScreenViewController(presenter: presenter)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationControllerAPI?.present(navigationController, animated: true, completion: nil)
    }
    
    private func showInelligibleCurrency(with currency: FiatCurrency) {
        let presenter = SimpleBuyIneligibleCurrencyScreenPresenter(
            currency: currency,
            stateService: stateService
        )
        let controller = SimpleBuyIneligibleCurrencyViewController(presenter: presenter)
        controller.transitioningDelegate = sheetPresenter
        controller.modalPresentationStyle = .custom
        analyticsRecording.record(event: AnalyticsEvent.sbCurrencyUnsupported)
        topMostViewControllerProvider.topMostViewController?.present(controller, animated: true, completion: nil)
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
            cardListService: cardServiceProvider.cardList,
            creationService: serviceProvider.orderCreation(for: data.detailType.paymentMethod),
            confirmationService: serviceProvider.orderConfirmation,
            cancellationService: serviceProvider.orderCancellation,
            checkoutData: data
        )
        let presenter = CheckoutScreenPresenter(
            stateService: stateService,
            interactor: interactor
        )
        let viewController = CheckoutScreenViewController(using: presenter)
        present(viewController: viewController)
    }
    
    private func showPendingOrderCompletionScreen(for orderId: String, cryptoValue: CryptoValue) {
        let interactor = PendingOrderStateScreenInteractor(
            orderId: orderId,
            amount: cryptoValue,
            service: serviceProvider.orderCompletion
        )
        let presenter = PendingOrderStateScreenPresenter(
            stateService: stateService,
            interactor: interactor
        )
        let viewController = PendingStateViewController(
            presenter: presenter
        )
        present(viewController: viewController)
    }
    
    private func showCardAuthorization(with data: SimpleBuyOrderDetails) {
        let presenter = CardAuthorizationScreenPresenter(
            stateService: stateService,
            data: data.authorizationData!
        )
        let viewController = CardAuthorizationScreenViewController(
            presenter: presenter
        )
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
        let viewController = PendingStateViewController(presenter: presenter)
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
            exchangeProvider: exchangeProvider,
            fiatCurrencyService: serviceProvider.settings,
            pairsService: serviceProvider.supportedPairsInteractor,
            eligibilityService: serviceProvider.eligibility,
            paymentMethodTypesService: serviceProvider.paymentMethodTypes,
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
        return BottomSheetPresenting(ignoresBackroundTouches: true)
    }()
}
