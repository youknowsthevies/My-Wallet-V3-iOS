// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import FeatureAuthenticationDomain
import FeatureSettingsDomain
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import SafariServices
import SwiftUI
import ToolKit
import UIKit
import WebKit

public protocol AppCoordinating: AnyObject {
    func showFundTrasferDetails(fiatCurrency: FiatCurrency, isOriginDeposit: Bool)
}

public protocol AuthenticationCoordinating: AnyObject {
    func enableBiometrics()
    func changePin()
}

public protocol ExchangeCoordinating: AnyObject {
    func start(from viewController: UIViewController)
}

public enum AccountLinkingFlowPresenterCompletion {
    case dismiss
    case select(PaymentMethod)
}

public protocol AccountLinkingFlowPresenterAPI {

    func presentAccountLinkingFlow(
        from presenter: UIViewController,
        filter: @escaping (PaymentMethodType) -> Bool,
        completion: @escaping (AccountLinkingFlowPresenterCompletion) -> Void
    )
}

public protocol PaymentMethodsLinkerAPI {
    func routeToCardLinkingFlow(from viewController: UIViewController, completion: @escaping () -> Void)
}

public protocol KYCRouterAPI {

    func presentLimitsOverview(from presenter: UIViewController)
}

final class SettingsRouter: SettingsRouterAPI {

    typealias AnalyticsEvent = AnalyticsEvents.Settings

    let actionRelay = PublishRelay<SettingsScreenAction>()
    let previousRelay = PublishRelay<Void>()
    let navigationRouter: NavigationRouterAPI

    // MARK: - Routers

    private lazy var updateMobileRouter: UpdateMobileRouter = {
        UpdateMobileRouter(navigationRouter: navigationRouter)
    }()

    private lazy var backupRouterAPI: BackupFundsRouterAPI = {
        BackupFundsRouter(entry: .settings, navigationRouter: navigationRouter)
    }()

    // MARK: - Private

    private let guidRepositoryAPI: FeatureAuthenticationDomain.GuidRepositoryAPI
    private let analyticsRecording: AnalyticsEventRecorderAPI
    private let alertPresenter: AlertViewPresenter

    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private unowned let tabSwapping: TabSwapping
    private unowned let appCoordinator: AppCoordinating
    private unowned let authenticationCoordinator: AuthenticationCoordinating
    private unowned let exchangeCoordinator: ExchangeCoordinating
    private unowned let appStoreOpener: AppStoreOpening
    private let passwordRepository: PasswordRepositoryAPI
    private let wallet: WalletRecoveryVerifing
    private let repository: DataRepositoryAPI
    private let pitConnectionAPI: PITConnectionStatusProviding
    private let builder: SettingsBuilding
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let featureFlagsService: FeatureFlagsServiceAPI
    private let logoutService: LogoutServiceAPI

    private let kycRouter: KYCRouterAPI

    private var cardRouter: CardRouter!
    private var linkBankFlowRouter: LinkBankFlowStarter?
    private let paymentMethodLinker: PaymentMethodsLinkerAPI
    private let presentAccountLinkingFlow: AccountLinkingFlowPresenterAPI

    private let addCardCompletionRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    private var cancellables = Set<AnyCancellable>()

    private var topViewController: UIViewController {
        let topViewController = navigationRouter.topMostViewControllerProvider.topMostViewController
        guard let viewController = topViewController else {
            fatalError("Failed to present open banking flow, no view controller available for presentation")
        }
        return viewController
    }

    init(
        appCoordinator: AppCoordinating = resolve(),
        builder: SettingsBuilding = SettingsBuilder(),
        wallet: WalletRecoveryVerifing = resolve(),
        guidRepositoryAPI: FeatureAuthenticationDomain.GuidRepositoryAPI = resolve(),
        authenticationCoordinator: AuthenticationCoordinating = resolve(),
        exchangeCoordinator: ExchangeCoordinating = resolve(),
        appStoreOpener: AppStoreOpening = resolve(),
        navigationRouter: NavigationRouterAPI = resolve(),
        analyticsRecording: AnalyticsEventRecorderAPI = resolve(),
        alertPresenter: AlertViewPresenter = resolve(),
        kycRouter: KYCRouterAPI = resolve(),
        cardListService: CardListServiceAPI = resolve(),
        paymentMethodTypesService: PaymentMethodTypesServiceAPI = resolve(),
        pitConnectionAPI: PITConnectionStatusProviding = resolve(),
        tabSwapping: TabSwapping = resolve(),
        passwordRepository: PasswordRepositoryAPI = resolve(),
        repository: DataRepositoryAPI = resolve(),
        paymentMethodLinker: PaymentMethodsLinkerAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve(),
        presentAccountLinkingFlow: AccountLinkingFlowPresenterAPI = resolve(),
        logoutService: LogoutServiceAPI = resolve()
    ) {
        self.wallet = wallet
        self.appCoordinator = appCoordinator
        self.builder = builder
        self.authenticationCoordinator = authenticationCoordinator
        self.exchangeCoordinator = exchangeCoordinator
        self.appStoreOpener = appStoreOpener
        self.navigationRouter = navigationRouter
        self.alertPresenter = alertPresenter
        self.analyticsRecording = analyticsRecording
        self.kycRouter = kycRouter
        self.tabSwapping = tabSwapping
        self.guidRepositoryAPI = guidRepositoryAPI
        self.paymentMethodTypesService = paymentMethodTypesService
        self.pitConnectionAPI = pitConnectionAPI
        self.passwordRepository = passwordRepository
        self.repository = repository
        self.paymentMethodLinker = paymentMethodLinker
        self.analyticsRecorder = analyticsRecorder
        self.featureFlagsService = featureFlagsService
        self.presentAccountLinkingFlow = presentAccountLinkingFlow
        self.logoutService = logoutService

        previousRelay
            .bindAndCatch(weak: self) { (self) in
                self.dismiss()
            }
            .disposed(by: disposeBag)

        actionRelay
            .bindAndCatch(weak: self) { (self, action) in
                self.handle(action: action)
            }
            .disposed(by: disposeBag)

        addCardCompletionRelay
            .bindAndCatch(weak: self) { (self) in
                cardListService
                    .fetchCards()
                    .subscribe()
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
    }

    func makeViewController() -> SettingsViewController {
        let interactor = SettingsScreenInteractor(
            pitConnectionAPI: pitConnectionAPI,
            wallet: wallet,
            paymentMethodTypesService: paymentMethodTypesService,
            authenticationCoordinator: authenticationCoordinator
        )
        let presenter = SettingsScreenPresenter(interactor: interactor, router: self)
        return SettingsViewController(presenter: presenter)
    }

    func presentSettings() {
        navigationRouter.present(viewController: makeViewController(), using: .modalOverTopMost)
    }

    func dismiss() {
        guard let navController = navigationRouter.navigationControllerAPI else { return }
        if navController.viewControllersCount > 1 {
            navController.popViewController(animated: true)
        } else {
            navController.dismiss(animated: true, completion: nil)
            navigationRouter.navigationControllerAPI = nil
        }
    }

    private func handle(action: SettingsScreenAction) {
        switch action {
        case .showURL(let url):
            let viewController = UIHostingController(
                rootView: SettingsWebView(request: .init(url: url))
            )
            viewController.rootView.updateTitle = { [weak viewController] title in
                viewController?.title = title
            }
            navigationRouter.present(
                viewController: viewController
            )
        case .launchChangePassword:
            let interactor = ChangePasswordScreenInteractor(passwordAPI: passwordRepository)
            let presenter = ChangePasswordScreenPresenter(previousAPI: self, interactor: interactor)
            let controller = ChangePasswordViewController(presenter: presenter)
            navigationRouter.present(viewController: controller)
        case .showRemoveCardScreen(let data):
            let viewController = builder.removeCardPaymentMethodViewController(cardData: data)
            viewController.transitioningDelegate = sheetPresenter
            viewController.modalPresentationStyle = .custom
            topViewController.present(viewController, animated: true, completion: nil)
        case .showRemoveBankScreen(let data):
            let viewController = builder.removeBankPaymentMethodViewController(beneficiary: data)
            viewController.transitioningDelegate = sheetPresenter
            viewController.modalPresentationStyle = .custom
            topViewController.present(viewController, animated: true, completion: nil)
        case .showAddCardScreen:
            let presenter = topViewController
            paymentMethodLinker.routeToCardLinkingFlow(from: presenter) { [addCardCompletionRelay] in
                presenter.dismiss(animated: true) {
                    addCardCompletionRelay.accept(())
                }
            }
        case .showAddBankScreen(let fiatCurrency):
            switch fiatCurrency {
            case .USD:
                showLinkBankFlow()
            case .GBP, .EUR:
                featureFlagsService
                    .isEnabled(.remote(.openBanking))
                    .if(
                        then: { [weak self] in
                            guard let self = self else { return }
                            self.showLinkOpenBankingFlow(currency: fiatCurrency)
                        },
                        else: { [weak self] in
                            guard let self = self else { return }
                            self.showFundTransferDetails(currency: fiatCurrency)
                        }
                    )
                    .store(in: &cancellables)
            default:
                showFundTransferDetails(currency: fiatCurrency)
            }
        case .showAppStore:
            appStoreOpener.openAppStore()
        case .showBackupScreen:
            backupRouterAPI.start()
        case .showChangePinScreen:
            authenticationCoordinator.changePin()
        case .showCurrencySelectionScreen:
            let settingsService: FiatCurrencySettingsServiceAPI = resolve()
            settingsService
                .fiatCurrency
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] currency in
                    self?.showFiatCurrencySelectionScreen(selectedCurrency: currency)
                })
                .disposed(by: disposeBag)
        case .launchWebLogin:
            let presenter = WebLoginScreenPresenter(service: WebLoginQRCodeService())
            let viewController = WebLoginScreenViewController(presenter: presenter)
            viewController.modalPresentationStyle = .overFullScreen
            navigationRouter.present(viewController: viewController)
        case .promptGuidCopy:
            guidRepositoryAPI.guid
                .map(weak: self) { _, value -> String in
                    value ?? ""
                }
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] guid in
                    guard let self = self else { return }
                    let alert = UIAlertController(
                        title: LocalizationConstants.AddressAndKeyImport.copyWalletId,
                        message: LocalizationConstants.AddressAndKeyImport.copyWarning,
                        preferredStyle: .actionSheet
                    )
                    let copyAction = UIAlertAction(
                        title: LocalizationConstants.AddressAndKeyImport.copyCTA,
                        style: .destructive,
                        handler: { [weak self] _ in
                            guard let self = self else { return }
                            self.analyticsRecording.record(event: AnalyticsEvent.settingsWalletIdCopied)
                            UIPasteboard.general.string = guid
                        }
                    )
                    let cancelAction = UIAlertAction(title: LocalizationConstants.cancel, style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    alert.addAction(copyAction)
                    guard let navController = self.navigationRouter.navigationControllerAPI as? UINavigationController else { return }
                    navController.present(alert, animated: true)
                })
                .disposed(by: disposeBag)

        case .presentTradeLimits:
            kycRouter.presentLimitsOverview(from: topViewController)

        case .launchPIT:
            guard let supportURL = URL(string: Constants.Url.exchangeSupport) else { return }
            let startPITCoordinator = { [weak self] in
                guard let self = self else { return }
                guard let navController = self.navigationRouter.navigationControllerAPI as? UINavigationController else { return }
                self.exchangeCoordinator.start(from: navController)
            }
            let launchPIT = AlertAction(
                style: .confirm(LocalizationConstants.Exchange.Launch.launchExchange),
                metadata: .block(startPITCoordinator)
            )
            let contactSupport = AlertAction(
                style: .default(LocalizationConstants.Exchange.Launch.contactSupport),
                metadata: .url(supportURL)
            )
            let model = AlertModel(
                headline: LocalizationConstants.Exchange.title,
                body: nil,
                actions: [launchPIT, contactSupport],
                image: #imageLiteral(resourceName: "exchange-icon-small"),
                dismissable: true,
                style: .sheet
            )
            let alert = AlertView.make(with: model) { [weak self] action in
                guard let self = self else { return }
                guard let metadata = action.metadata else { return }
                switch metadata {
                case .block(let block):
                    block()
                case .url(let support):
                    let controller = SFSafariViewController(url: support)
                    self.navigationRouter.present(viewController: controller)
                case .dismiss,
                     .pop,
                     .payload:
                    break
                }
            }
            alert.show()
        case .showUpdateEmailScreen:
            let interactor = UpdateEmailScreenInteractor()
            let presenter = UpdateEmailScreenPresenter(emailScreenInteractor: interactor)
            let controller = UpdateEmailScreenViewController(presenter: presenter)
            navigationRouter.present(viewController: controller)
        case .showUpdateMobileScreen:
            updateMobileRouter.start()
        case .logout:
            logoutService.logout()
        case .none:
            break
        }
    }

    private func showFundTransferDetails(currency: FiatCurrency) {
        appCoordinator.showFundTrasferDetails(fiatCurrency: currency, isOriginDeposit: false)
    }

    private func showLinkOpenBankingFlow(currency: FiatCurrency) {
        let viewController = topViewController
        presentAccountLinkingFlow
            .presentAccountLinkingFlow(
                from: viewController,
                filter: { type in
                    type.method.isFunds || type.method.isBankTransfer
                },
                completion: { [weak self] result in
                    guard let self = self else { return }
                    viewController.dismiss(animated: true) {
                        switch result {
                        case .dismiss:
                            break
                        case .select(let method):
                            switch method.type {
                            case .funds:
                                self.showFundTransferDetails(currency: currency)
                            case .bankTransfer:
                                self.showLinkBankFlow()
                            default:
                                assertionFailure("Unsupported payment method: \(method)")
                            }
                        }
                    }
                }
            )
    }

    private func showLinkBankFlow() {
        let builder = LinkBankFlowRootBuilder()
        // we need to pass the the navigation controller so we can present and dismiss from within the flow.
        let router = builder.build()
        linkBankFlowRouter = router
        let flowDismissed: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.linkBankFlowRouter = nil
        }
        analyticsRecorder.record(event: AnalyticsEvents.New.Withdrawal.linkBankClicked(origin: .settings))
        router.startFlow()
            .takeUntil(.inclusive, predicate: { $0.isCloseEffect })
            .skipWhile { $0.shouldSkipEffect }
            .subscribe(onNext: { [weak self] effect in
                guard case .closeFlow(let isInteractive) = effect, !isInteractive else {
                    flowDismissed()
                    return
                }
                self?.navigationRouter.navigationControllerAPI?.dismiss(animated: true, completion: flowDismissed)
            })
            .disposed(by: disposeBag)
    }

    private func showFiatCurrencySelectionScreen(selectedCurrency: FiatCurrency) {
        let selectionService = FiatCurrencySelectionService(defaultSelectedData: selectedCurrency)
        let interactor = SelectionScreenInteractor(service: selectionService)
        let presenter = SelectionScreenPresenter(
            title: LocalizationConstants.Settings.SelectCurrency.title,
            searchBarPlaceholder: LocalizationConstants.Settings.SelectCurrency.searchBarPlaceholder,
            interactor: interactor
        )
        let viewController = SelectionScreenViewController(presenter: presenter)
        viewController.isModalInPresentation = true
        navigationRouter.present(viewController: viewController)

        interactor.selectedIdOnDismissal
            .map { FiatCurrency(code: $0)! }
            .flatMap { currency -> Single<FiatCurrency> in
                let settings: FiatCurrencySettingsServiceAPI = resolve()
                return settings
                    .update(
                        currency: currency,
                        context: .settings
                    )
                    .andThen(Single.just(currency))
            }
            .observeOn(MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] currency in
                    guard let self = self else { return }
                    // TODO: Remove this and `fiatCurrencySelected` once `ReceiveBTC` and
                    /// `SendBTC` are replaced with Swift implementations.
                    NotificationCenter.default.post(name: .fiatCurrencySelected, object: nil)
                    self.analyticsRecording.record(events: [
                        AnalyticsEvents.Settings.settingsCurrencySelected(currency: currency.code),
                        AnalyticsEvents.New.Settings.settingsCurrencyClicked(currency: currency.code)
                    ])
                },
                onError: { [weak self] _ in
                    guard let self = self else { return }
                    self.alertPresenter.standardError(
                        message: LocalizationConstants.GeneralError.loadingData
                    )
                }
            )
            .disposed(by: disposeBag)
    }

    private lazy var sheetPresenter: BottomSheetPresenting = {
        BottomSheetPresenting()
    }()
}

struct SettingsWebView: View {

    let request: URLRequest
    var updateTitle: ((String?) -> Void)?

    var body: some View {
        WebView(request: request, updateTitle: updateTitle)
            .ignoresSafeArea(.container, edges: .bottom)
    }
}

struct WebView: UIViewRepresentable {

    let request: URLRequest
    var updateTitle: ((String?) -> Void)?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {

        var parent: WebView

        init(_ webView: WebView) {
            parent = webView
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.title") { response, _ in
                self.parent.updateTitle?(response as? String)
            }
        }
    }
}
